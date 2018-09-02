SMIp = SMI_Proxy;

ret = SMIp_OpenConnection(SMIp, '192.168.2.2', 8888); % IP of the host

ret = SMIp_StartRecording(SMIp);
pause(4);
ret = SMIp_SendImageMessage(SMIp, 'a.bmp');
pause(1);
ret = SMIp_SendImageMessage(SMIp, 'b.bmp');
pause(1);

ret = SMIp_StopRecording(SMIp);


ret = SMIp_SaveDataRecording( ...
                SMIp, ...
                'C:\SMI_Data\test2.idf', ... % Where the data will be saved
                'Descr1', ...
                'User2', ...
                1); % Overwrite - 1 or 0


ret = SMIp_CloseConnection(SMIp);