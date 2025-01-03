### **คู่มือทดสอบ SSL/TLS**

เอกสารนี้แนะนำขั้นตอนการทดสอบการตั้งค่า SSL/TLS บนเซิร์ฟเวอร์โดยใช้เครื่องมือ CLI เช่น `openssl`, `wget` และ `curl`

---

#### **1. ทดสอบ SSL ด้วย OpenSSL**
##### **a. การเชื่อมต่อ SSL พื้นฐาน**
ทดสอบการเชื่อมต่อ SSL กับเซิร์ฟเวอร์:
```bash
openssl s_client -connect localhost:4200 -servername localhost
```

**คำอธิบาย**:
- เชื่อมต่อกับเซิร์ฟเวอร์ `localhost` บนพอร์ต `4200`
- ระบุชื่อเซิร์ฟเวอร์ (`localhost`) เพื่อใช้ SNI (Server Name Indication)

---

##### **b. ดูรายละเอียดใบรับรอง**
แสดงรายละเอียดใบรับรองที่เซิร์ฟเวอร์ส่งกลับมา:
```bash
openssl s_client -connect localhost:4200 -servername localhost | openssl x509 -text -noout
```

**คำอธิบาย**:
- เชื่อมต่อกับเซิร์ฟเวอร์และส่งข้อมูลใบรับรองไปยัง `openssl x509` เพื่อแสดงในรูปแบบที่อ่านง่าย

---

##### **c. ตรวจสอบใบรับรองกับ Root CA**
ตรวจสอบใบรับรองเซิร์ฟเวอร์เทียบกับไฟล์ Root CA:
```bash
openssl s_client -connect localhost:4200 -servername localhost -CAfile RootCA.crt
```

**คำอธิบาย**:
- ตรวจสอบว่าใบรับรองเซิร์ฟเวอร์ถูกต้องและเชื่อถือได้โดยใช้ไฟล์ `RootCA.crt`

---

#### **2. ทดสอบ SSL ด้วย Wget**
ดาวน์โหลดเนื้อหาจากเซิร์ฟเวอร์โดยไม่ตรวจสอบใบรับรอง:
```bash
wget --no-check-certificate https://localhost:443
```

**คำอธิบาย**:
- ข้ามการตรวจสอบใบรับรอง (เหมาะสำหรับการดีบักเบื้องต้น)
- เชื่อมต่อกับ `localhost` บนพอร์ต `443`

---

#### **3. ทดสอบ SSL ด้วย Curl**
##### **a. การเชื่อมต่อพื้นฐานด้วย Curl**
การเชื่อมต่อ SSL แบบแสดงข้อมูลแบบละเอียด:
```bash
curl -v https://localhost:443
```

**คำอธิบาย**:
- แสดงรายละเอียดของการจับมือ SSL (handshake) และการตอบกลับของเซิร์ฟเวอร์

---

##### **b. ตรวจสอบ SSL ด้วย Root CA**
ทดสอบการตั้งค่า SSL ของเซิร์ฟเวอร์โดยใช้ Root CA:
```bash
curl -v https://localhost:443 --cacert RootCA.crt
```

**คำอธิบาย**:
- ตรวจสอบใบรับรองของเซิร์ฟเวอร์เทียบกับ `RootCA.crt`
- ใช้สำหรับการทดสอบห่วงโซ่ใบรับรอง (Certificate Chain)

---

#### **ผลลัพธ์ที่คาดหวัง**
1. **การเชื่อมต่อสำเร็จ**:
   - ไม่มีข้อผิดพลาดในระหว่างการ handshake
   - แสดงข้อมูลใบรับรองของเซิร์ฟเวอร์ (สำหรับ OpenSSL)
   - ได้รับการตอบสนองจากเซิร์ฟเวอร์ (สำหรับ Curl และ Wget)

2. **ข้อผิดพลาด**:
   - ตรวจสอบว่าเปิดพอร์ต (เช่น `4200`, `443`) ไว้แล้ว
   - ตรวจสอบว่าเซิร์ฟเวอร์รองรับ SSL/TLS
   - ตรวจสอบว่าใบรับรองถูกต้องและใช้งานอยู่

---

### **ข้อมูลเพิ่มเติม**
- [เอกสาร OpenSSL](https://www.openssl.org/docs/)
- [เอกสาร Curl](https://curl.se/docs/)
- [เอกสาร Wget](https://www.gnu.org/software/wget/manual/)

---

บันทึกไฟล์นี้เป็น **`SSL_Testing_TH.md`** เพื่อใช้เป็นคู่มือในอนาคต! 😊