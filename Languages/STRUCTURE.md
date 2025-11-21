# ATG Hub Languages - File Structure 📂

## 📁 โครงสร้างไฟล์ทั้งหมด

```
Languages/
├── 📄 init.lua              # ระบบหลักจัดการภาษา (Main System)
├── 🌐 en.lua                # ภาษาอังกฤษ (English)
├── 🌐 th.lua                # ภาษาไทย (Thai)
├── 🌐 jp.lua                # ภาษาญี่ปุ่น (Japanese)
├── 🌐 cn.lua                # ภาษาจีนตัวย่อ (Chinese Simplified)
├── 📖 README.md             # เอกสารฉบับเต็ม (Full Documentation)
├── ⚡ QUICKSTART.md         # คู่มือเริ่มต้นแบบเร็ว (Quick Guide)
├── 💡 example.lua           # ตัวอย่างการใช้งาน (Usage Examples)
├── 🧪 test.lua              # สคริปต์ทดสอบระบบ (Test Script)
└── 📋 STRUCTURE.md          # ไฟล์นี้ - โครงสร้างไฟล์
```

---

## 📄 รายละเอียดไฟล์

### 1. **init.lua** (ไฟล์หลัก)
**หน้าที่:** ระบบจัดการภาษาหลัก

**ขนาด:** ~5 KB

**Features:**
- โหลดไฟล์ภาษาจาก GitHub
- จัดการการเปลี่ยนภาษา
- Variable replacement
- Auto-detection
- Fallback system

**URL:**
```
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/init.lua
```

---

### 2. **en.lua** (ภาษาอังกฤษ)
**หน้าที่:** คลังคำแปลภาษาอังกฤษ

**Translation Keys:** 100+ keys

**หมวดหมู่:**
- Window & General (10 keys)
- Tabs (10 keys)
- Player Info (8 keys)
- Auto Features (15 keys)
- Selections (8 keys)
- Events (4 keys)
- Auto Play (15 keys)
- Screen & GUI (6 keys)
- Humanoid Settings (7 keys)
- Players Tab (3 keys)
- Server Tab (8 keys)
- Notifications (4 keys)
- Actions (12 keys)
- Status (7 keys)
- Common (8 keys)
- Numbers & Units (6 keys)
- Errors & Warnings (5 keys)
- Misc (5 keys)

**URL:**
```
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/en.lua
```

---

### 3. **th.lua** (ภาษาไทย)
**หน้าที่:** คลังคำแปลภาษาไทย

**Translation Keys:** 100+ keys (เหมือน en.lua)

**การแปล:** แปลครบทุก key พร้อมคำศัพท์ที่เหมาะกับเกม

**URL:**
```
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/th.lua
```

---

### 4. **jp.lua** (ภาษาญี่ปุ่น)
**หน้าที่:** คลังคำแปลภาษาญี่ปุ่น

**Translation Keys:** 100+ keys (เหมือน en.lua)

**การแปล:** แปลเป็นภาษาญี่ปุ่นธรรมชาติ

**URL:**
```
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/jp.lua
```

---

### 5. **cn.lua** (ภาษาจีนตัวย่อ)
**หน้าที่:** คลังคำแปลภาษาจีน (Simplified Chinese)

**Translation Keys:** 100+ keys (เหมือน en.lua)

**การแปล:** แปลเป็นภาษาจีนกลาง (简体中文)

**URL:**
```
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/cn.lua
```

---

### 6. **README.md** (เอกสารหลัก)
**หน้าที่:** เอกสารฉบับเต็มและละเอียด

**เนื้อหา:**
- Features ทั้งหมด
- ภาษาที่รองรับ
- วิธีติดตั้ง
- ตัวอย่างการใช้งาน
- API Reference ครบถ้วน
- วิธีเพิ่มภาษาใหม่
- Best Practices
- Troubleshooting

**ขนาด:** ~15 KB

---

### 7. **QUICKSTART.md** (คู่มือเร็ว)
**หน้าที่:** คู่มือเริ่มต้นใช้งานภายใน 3 นาที

**เนื้อหา:**
- วิธีโหลด
- การใช้งานพื้นฐาน
- ตัวอย่าง Fluent UI
- Functions ที่ใช้บ่อย
- Keys ที่ใช้บ่อย
- Copy-paste ready code

**ขนาด:** ~3 KB

---

### 8. **example.lua** (ตัวอย่างครบถ้วน)
**หน้าที่:** ตัวอย่างการใช้งานทุกแบบ

**เนื้อหา:**
- Basic Setup
- Basic Usage
- Using with Fluent UI
- Variable Replacement
- Language Switching
- Language Selector UI
- Creating UI Elements
- Advanced Features
- Helper Functions
- Complete Example

**ขนาด:** ~8 KB

---

### 9. **test.lua** (สคริปต์ทดสอบ)
**หน้าที่:** ทดสอบระบบภาษาว่าทำงานถูกต้อง

**การทดสอบ:**
- ✅ โหลดระบบสำเร็จ
- ✅ ภาษาเริ่มต้นถูกต้อง
- ✅ มีภาษาครบถ้วน
- ✅ Translation keys ทำงาน
- ✅ การเปลี่ยนภาษาทำงาน
- ✅ Variable replacement ทำงาน

**วิธีใช้:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/test.lua"))()
```

**ขนาด:** ~3 KB

---

### 10. **STRUCTURE.md** (ไฟล์นี้)
**หน้าที่:** อธิบายโครงสร้างไฟล์ทั้งหมด

**เนื้อหา:**
- โครงสร้างโฟลเดอร์
- รายละเอียดแต่ละไฟล์
- ขนาดและ URL
- แนวทางการพัฒนา

---

## 📊 สรุปขนาดไฟล์

| ไฟล์ | ประเภท | ขนาดโดยประมาณ | จำเป็น |
|------|--------|----------------|--------|
| init.lua | Code | ~5 KB | ✅ Required |
| en.lua | Data | ~4 KB | ✅ Required |
| th.lua | Data | ~5 KB | ✅ Required |
| jp.lua | Data | ~5 KB | ✅ Required |
| cn.lua | Data | ~4 KB | ✅ Required |
| README.md | Docs | ~15 KB | 📖 Recommended |
| QUICKSTART.md | Docs | ~3 KB | 📖 Recommended |
| example.lua | Code | ~8 KB | 💡 Optional |
| test.lua | Code | ~3 KB | 🧪 Optional |
| STRUCTURE.md | Docs | ~3 KB | 📋 Optional |

**Total Size:** ~55 KB

---

## 🔗 GitHub URLs

### Raw Files (สำหรับ loadstring)
```
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/init.lua
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/en.lua
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/th.lua
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/jp.lua
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/cn.lua
https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/test.lua
```

### GitHub Pages (สำหรับอ่าน)
```
https://github.com/ATGFAIL/ATGHub/blob/main/Languages/README.md
https://github.com/ATGFAIL/ATGHub/blob/main/Languages/QUICKSTART.md
https://github.com/ATGFAIL/ATGHub/blob/main/Languages/example.lua
https://github.com/ATGFAIL/ATGHub/tree/main/Languages
```

---

## 🚀 แนวทางการพัฒนาต่อ

### เพิ่มภาษาใหม่
1. สร้างไฟล์ `kr.lua` (Korean) หรือภาษาอื่นๆ
2. Copy structure จาก `en.lua`
3. แปลทุก key
4. เพิ่มการโหลดใน `init.lua`
5. Update documentation

### เพิ่ม Translation Keys
1. เพิ่ม key ใน `en.lua` (reference)
2. เพิ่ม key เดียวกันในทุกภาษา
3. Test ด้วย `test.lua`
4. Update documentation

### ปรับปรุงระบบ
- เพิ่ม caching mechanism
- เพิ่ม async loading
- สนับสนุน custom translations
- เพิ่ม plural forms support

---

## 📝 Version History

### Version 1.0.0 (Current)
- ✅ รองรับ 4 ภาษา (EN, TH, JP, CN)
- ✅ 100+ translation keys
- ✅ Auto-detection
- ✅ Variable replacement
- ✅ Fallback system
- ✅ Complete documentation

### Future Versions
- 🚧 Korean language (KR)
- 🚧 Spanish language (ES)
- 🚧 Plural forms support
- 🚧 Context-aware translations

---

## 🎯 ไฟล์ไหนใช้เมื่อไหร่

### สำหรับผู้ใช้ทั่วไป
1. เริ่มต้นที่ **QUICKSTART.md**
2. ใช้ **init.lua** ในโค้ด
3. ดูตัวอย่างจาก **example.lua**

### สำหรับนักพัฒนา
1. อ่าน **README.md** ทั้งหมด
2. ศึกษา **example.lua**
3. ทดสอบด้วย **test.lua**
4. อ้างอิง **STRUCTURE.md** (ไฟล์นี้)

### สำหรับการแปลภาษา
1. ดูโครงสร้างจาก **en.lua**
2. Copy และแปล keys
3. ทดสอบด้วย **test.lua**

---

## ✅ Checklist สำหรับการ Deploy

- [ ] ทุกไฟล์มี URL ที่ถูกต้อง
- [ ] ทดสอบด้วย test.lua แล้ว
- [ ] Documentation ครบถ้วน
- [ ] ตัวอย่างทำงานได้
- [ ] แต่ละภาษามี keys ครบเท่ากัน
- [ ] GitHub repository สาธารณะ
- [ ] Raw URLs เข้าถึงได้

---

**Created by ATG Team** 🚀
**Version:** 1.0.0
**Last Updated:** 2024
