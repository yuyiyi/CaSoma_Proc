%% 1
a = arduino('COM3');

%-- specify pin mode 
 %a.pinMode(4,'input'); 
 a.pinMode(13,'output');
%%
 %-- digital i/o 
 %a.digitalRead(4) % read pin 4 
 a.digitalWrite(13,0) % write 0 to pin 13

 %-- analog i/o 
 a.analogRead(5) % read analog pin 5 
 %a.analogWrite(9, 155) % write 155 to analog pin 9
 
 pause(2)
  a.digitalWrite(13,1) % write 1 to pin 13
  a.analogRead(5) % read analog pin 5 
 %%
 delete(a)
 