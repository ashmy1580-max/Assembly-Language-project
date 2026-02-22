# ✈️ Airline Reservation System (8086 Assembly)

This is a console-based Airline Reservation System developed using 8086 Assembly Language (MASM/TASM syntax).  
The system allows users to add, view, and search airline reservations using DOS interrupts.

---

## 📌 Features

- Add new reservation
- Store passenger name
- Store passport number
- Store departure city
- Store arrival city
- Show all reservations
- Search reservation by full passport number
- Maximum 10 reservations supported
- Menu-driven interface

---

## 🛠 Technologies Used

- 8086 Assembly Language
- DOS Interrupt 21h
- MASM / TASM Assembler
- EMU8086 (or DOSBox)

---

## 📂 Program Structure

### 1️⃣ Add Reservation
- Takes user input for:
  - Name
  - Passport Number
  - Departure City
  - Arrival City
- Stores data in arrays
- Each record uses 20 bytes
- Maximum 10 records allowed

### 2️⃣ Show All
- Displays all saved reservations
- Prints:
  - Name
  - Passport
  - Route (From → To)

### 3️⃣ Search (Full Passport Match)
- User enters passport number
- Program compares character-by-character
- If match found → displays record
- If not found → shows error message

---

## 🧠 Concepts Used

- Data segment and stack segment
- Arrays and memory indexing
- Multiplication for offset calculation (count × 20)
- Loop instruction
- String comparison logic
- Custom input routine using INT 21h
- Menu-driven control using CMP and JMP

---

## ▶️ How to Run

1. Open EMU8086 or DOSBox
2. Assemble the code using MASM/TASM
3. Run the program
4. Choose options from the menu

---

## 📊 Data Storage Logic

- Each field has 200 bytes allocated
- Each reservation uses 20 bytes
- Offset calculation:
  
  offset = count × 20

- Arrays used:
  - names
  - passports
  - departures
  - arrivals

---

## 👩‍💻 Author

Aramish Ashfaq  
BSCS Student  
Semester 2 – Digital Logic & Assembly Programming

---

## 📌 Future Improvements

- Add Delete option
- Add File handling
- Improve search (partial match)
- Improve UI formatting
