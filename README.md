## Smart_Contract
## การคำนวณเงื่อนไขการแพ้ชนะ 
**โดยกรณีชนะจะมีทั้งหมด ตัวเลือกละ 2 ทาง ตามภาพ  ซึ่งได้ทำการหาความสัมพันธ์ และ mod ด้วย 5 ตามภาพ**
![IMG_7544](https://github.com/user-attachments/assets/4a659e3c-af7d-4a72-8be8-dd0d437a7f29)

## ป้องกันการ lock เงินไว้ใน contract
```function checkTimeout() public { // ใช้ฟังก์ชันการเช็กเวลารอผู้เล่นเลือก
        require(numPlayer == 2, "Only 2 players naa"); //กำหนดให้มีผู้เล่น 2 คน
        if (block.timestamp >= startTime + gameTimeout && numInput < 2) { //ถ้า เวลารอมากกว่าหรือเท่ากับเวลาเริ่ม(คนใดคนนึงเลือกตัวเลือกหรืออินพุตไม่เท่ากับ 0 ) + เวลาที่ตั้งไว้ว่าจะรอ (2 นาที)
            address payable account0 = payable(players[0]); //กำหนดจ่ายเงิน
            address payable account1 = payable(players[1]); //กำหนดจ่ายเงิน
            if (player_not_played[players[0]]) {  //ทำการคืนเงินผู้เล่นคนที่ 1 
                account0.transfer(reward);
            }
            if (player_not_played[players[1]]) { //ทำการคืนเงินผู้เล่นคนที่ 2
                account1.transfer(reward);
            }
            _resetGame(); //เรียกใช้ฟังก์ชันรีเซตเกม
        }
    }
```



    
## ทำการซ่อน choice และ commit
![Screenshot 2025-03-08 045739](https://github.com/user-attachments/assets/1b4a550f-3eae-401b-9520-3b8eb51d0c09)
## นำค่า byte32 ไปใช้ใน Convert ทำการ getHash ไปใช้ 
![Screenshot 2025-03-08 045558](https://github.com/user-attachments/assets/74e235b9-8c6c-47ab-8e08-976c54821892)

``` function commitChoice(uint choice) public {
        require(numPlayer == 2, "Only 2 players naa");
        require(player_not_played[msg.sender], "You have already committed");
        require(choice >= 0 && choice <= 4, "Invalid choice ja");
        bytes32 commitment = keccak256(abi.encodePacked(choice));
        player_choice_hash[msg.sender] = commitment;
        player_not_played[msg.sender] = false;
        numInput++;
    }
```



    
## จัดการกับความล่าช้าที่ผู้เล่นไม่ครบทั้งสองคนเสียที
 ```function checkWaitingTimeout() public { //ฟังก์ชันการเช็กผู้เล่นคนที่ 2 
        require(numPlayer == 1); // จะต้องมีผู้เล่นก่อน 1 คน 
        if (block.timestamp >= startTime + waitingTime) { //ถ้า เวลารอมากกว่าหรือเท่ากับเวลาเริ่ม(คนที่ 1 เข้ามา ) + เวลาที่ตั้งไว้ว่าจะรอ (5 นาที)
            address payable player1 = payable(players[0]);  //กำหนดจ่ายให้ผู้เล่นคนแรก
            player1.transfer(reward);  // คืนเงินให้กับผู้เล่นคนแรก
            _resetGame(); //เรียกใช้ฟังก์ชันรีเซตเกม
        }
    }
```


    
## ทำการ reveal และนำ choice มาตัดสินผู้ชนะ
![Screenshot 2025-03-08 050100](https://github.com/user-attachments/assets/c060c5c2-5085-44d6-b483-22b461f5ea68)
``` function revealChoice(uint choice) public {
        require(numInput == 2, "Both players must commit first"); //เช็กว่าทั้ง 2 ผู้เล่นทำการคอมมิทมาเรียบร้อยแล้ว
        require(choice >= 0 && choice <= 4, "Invalid choice ja"); //เช็กคำตอบหากไม่อยู่ในตัวเลืือก
        require(keccak256(abi.encodePacked(choice)) == player_choice_hash[msg.sender], "Invalid reveal"); //นำ choice ที่ผู้เล่นส่งเข้ามาไปทำ Keccak256 Hash เพื่อเปรียบเทียบกับค่า Hash ที่เก็บไว้ใน player_choice_hash[msg.sender]
        revealedChoices[msg.sender] = choice; //บันทึกค่า
        if (revealedChoices[players[0]] > 0 && revealedChoices[players[1]] > 0) {  // ตรวจสอบว่าทั้ง 2 ผู้เล่นทำการเปิดตัวเลือกแล้ว
            _checkWinnerAndPay(); // หาผู้ชนะ
        }
    }
```

