#!/bin/bash

# ตรวจสอบว่าทำงานในโฟลเดอร์ที่ถูกต้อง
if [ ! -d "$(pwd)" ]; then
    echo "Error: Working directory is not accessible."
    exit 1
fi

# สร้าง Root CA
echo "Creating Root CA..."
openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:4096 \
-keyout RootCA.key -out RootCA.pem -subj "/C=TH/CN=Abdulloh-Root-CA" || { echo "Failed to create Root CA"; exit 1; }

# แปลง Root CA เป็น .crt
echo "Exporting Root CA to CRT format..."
openssl x509 -outform pem -in RootCA.pem -out RootCA.crt || { echo "Failed to export Root CA to .crt format"; exit 1; }

# สร้างไฟล์คอนฟิก CSR ชั่วคราว
CONFIG_FILE=$(mktemp)
cat <<EOF > "$CONFIG_FILE"
[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
countryName                = Country Name (2 letter code)
countryName_default        = TH
stateOrProvinceName        = State or Province Name (full name)
stateOrProvinceName_default = Songkhla
localityName               = Locality Name (eg, city)
localityName_default       = Hatyai
organizationName           = Organization Name (eg, company)
organizationName_default   = Development-Certificates
organizationalUnitName     = Organizational Unit Name (eg, section)
organizationalUnitName_default = IT-Developer-Department
commonName                 = Common Name (e.g. server FQDN or YOUR name)
commonName_default         = localhost
emailAddress               = Email Address
emailAddress_default       = abdulloh.mukem@gmail.com

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
DNS.2 = localhost.localdomain
IP.1  = 127.0.0.1
EOF

# สร้าง CSR และ Private Key สำหรับ localhost

openssl req -new -nodes -newkey rsa:4096 -keyout localhost.key -out localhost.csr \
-subj "/C=TH/ST=Songkhla/L=Hatyai/O=Development-Certificates/OU=IT-Developer-Department/CN=localhost/emailAddress=abdulloh.mukem@gmail.com" \
-config "$CONFIG_FILE" -reqexts req_ext || { echo "Failed to create localhost CSR"; exit 1; }

# ลบไฟล์คอนฟิก CSR ชั่วคราว
rm -f "$CONFIG_FILE"

# สร้างไฟล์คอนฟิก extfile ชั่วคราว
EXTFILE=$(mktemp)
cat <<EOF > "$EXTFILE"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
DNS.2 = localhost.localdomain
IP.1  = 127.0.0.1
EOF

# เซ็นใบรับรอง localhost ด้วย Root CA
echo "Signing localhost certificate with Root CA..."
openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial \
-extfile "$EXTFILE" -out localhost.crt || { echo "Failed to sign localhost certificate"; exit 1; }

# ลบไฟล์คอนฟิก extfile ชั่วคราว
rm -f "$EXTFILE"

# ตั้งค่าสิทธิ์ให้ไฟล์
chmod 600 RootCA.key localhost.key localhost.csr
chmod 644 RootCA.crt localhost.crt

# แสดงข้อมูลของ localhost.crt
echo "Displaying localhost certificate details..."
openssl x509 -in localhost.crt -text -noout || { echo "Failed to display localhost certificate"; exit 1; }

echo "Certificates created successfully."
