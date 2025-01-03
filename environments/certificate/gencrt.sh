openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:4096 -keyout RootCA.key -out RootCA.pem -subj "/C=US/CN=Example-Root-CA"
openssl x509 -outform pem -in RootCA.pem -out RootCA.crt
openssl req -new -nodes -newkey rsa:4096 -keyout localhost.key -out localhost.csr -subj "/C=US/ST=YourState/L=YourCity/O=Example-Certificates/CN=localhost.com"
openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -extfile extension.ext -out localhost.crt

chmod 600 RootCA.key           
chmod 644 RootCA.crt        
chmod 600 localhost.key   
chmod 644 localhost.crt    
chmod 600 localhost.csr   
# ls -l RootCA.key RootCA.crt localhost.key localhost.crt localhost.csr
openssl x509 -in localhost.crt -text -noout
