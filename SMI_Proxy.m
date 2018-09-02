% Currently implemented request types
% enum  RequestType
% {
% 0	KEEPALIVE,
% 1	GET_SMI_SYSTEM_INFO,
% 2	RET_SMI_SYSTEM_INFO,
% 3	GET_SMI_SEND_MSG,
% 4	RET_SMI_SEND_MSG,
% 5	GET_SMI_START_RECORD,
% 6	RET_SMI_START_RECORD,
% 7	GET_SMI_STOP_RECORD,
% 8	RET_SMI_STOP_RECORD,
% 9	GET_SMI_SAVE_RECORD,
% 10	RET_SMI_SAVE_RECORD,
% 11	ERROR_MSG
% };


classdef SMI_Proxy < handle
    methods 
        function ret = SMIp_OpenConnection(obj, proxy_addr, proxy_port, wait_ret)
            ret = -1;
            
            obj.flWaitReturn = wait_ret;

            % Open connection and file handle
            obj.udp_obj = udp(proxy_addr, proxy_port, 'InputBufferSize',1024, 'OutputBufferSize',1024);
            if (obj.udp_obj == 0) 
                return;
            end
            fopen(obj.udp_obj);
            
            % Format test packet
            sToSend = struct( ...
                'ClientID', 1, ...                          % Client ID
                'ServerID', 2, ...                          % Server ID
                'PacketID', 1, ...                          % Packet ID
                'ReplyToPacketID', 0, ...                   % Reply To Packet ID
                'Timestamp', todatenum(cdfepoch(now)), ...  % Time stamp
                'RequestType', 1, ...                       % Type: GET_SMI_SYSTEM_INFO
                'Data', 0);

            dataSent = obj.commStructToData(sToSend);
            
            % Send test packet
            fwrite(obj.udp_obj, dataSent);

            %if (obj.flWaitReturn)
                % Get reply to sent packet
                dataReceived = uint8(fread(obj.udp_obj, 1024));

                % PARSING RETURN DATA
                sReceived = obj.dataToCommStruct(dataReceived);

                if (sReceived.RequestType ~= 2)                 % Type: RET_SMI_SYSTEM_INFO
                    return;
                end
            %end            
            obj.flIsConnected = true;
            ret = 0;

        end
        
        function ret = SMIp_CloseConnection(obj)
            ret = -1;
            if (~obj.flIsConnected)
                return;
            end
            
            fclose(obj.udp_obj);
            
            obj.flIsConnected = false;
            obj.udp_obj = 0;
            ret = 0;
        end
        
        function ret = SMIp_StartRecording(obj)
            ret = -1;
            if (~obj.flIsConnected)
                return;
            end
            
            % Format function packet
            sToSend = struct( ...
                'ClientID', 1, ...                          % Client ID
                'ServerID', 2, ...                          % Server ID
                'PacketID', 1, ...                          % Packet ID
                'ReplyToPacketID', 0, ...                   % Reply To Packet ID
                'Timestamp', todatenum(cdfepoch(now)), ...  % Time stamp
                'RequestType', 5, ...                       % Type: GET_SMI_START_RECORD
                'Data', 0);

            dataSent = obj.commStructToData(sToSend);
            
            % Send function packet
            fwrite(obj.udp_obj, dataSent);

            if (obj.flWaitReturn)
                % Get reply to sent packet
                dataReceived = uint8(fread(obj.udp_obj, 1024));

                % PARSING RETURN DATA
                sReceived = obj.dataToCommStruct(dataReceived);

                if (sReceived.RequestType ~= 6)                 % Type: RET_SMI_START_RECORD
                    return;
                end
            end
            
            obj.flIsRecording = true;
            ret = 0;
        end
        
        function ret = SMIp_StopRecording(obj)
            ret = -1;
            if (~obj.flIsConnected)
                return;
            end
            
            % Format function packet
            sToSend = struct( ...
                'ClientID', 1, ...                          % Client ID
                'ServerID', 2, ...                          % Server ID
                'PacketID', 1, ...                          % Packet ID
                'ReplyToPacketID', 0, ...                   % Reply To Packet ID
                'Timestamp', todatenum(cdfepoch(now)), ...  % Time stamp
                'RequestType', 7, ...                       % Type: GET_SMI_STOP_RECORD
                'Data', 0);

            dataSent = obj.commStructToData(sToSend);
            
            % Send function packet
            fwrite(obj.udp_obj, dataSent);

            if (obj.flWaitReturn)
                % Get reply to sent packet
                dataReceived = uint8(fread(obj.udp_obj, 1024));

                % PARSING RETURN DATA
                sReceived = obj.dataToCommStruct(dataReceived);

                if (sReceived.RequestType ~= 8)                 % Type: RET_SMI_STOP_RECORD
                    return;
                end
            end
            
            obj.flIsRecording = false;
            ret = 0;
        end
        
        function ret = SMIp_SaveDataRecording( ...
                obj, ...
                FileName, ...
                Descr, ...
                User, ...
                Ovr)
            
            ret = -1;
            if (~obj.flIsConnected)
                return;
            end
            
            % Format function packet
            sToSend = struct( ...
                'ClientID', 1, ...                          % Client ID
                'ServerID', 2, ...                          % Server ID
                'PacketID', 1, ...                          % Packet ID
                'ReplyToPacketID', 0, ...                   % Reply To Packet ID
                'Timestamp', todatenum(cdfepoch(now)), ...  % Time stamp
                'RequestType', 9, ...                       % Type: GET_SMI_SAVE_RECORD
                'FileName', FileName, ...
                'Descr', Descr, ...
                'User', User, ...
                'Ovr', Ovr);

%             dataSent = obj.commStructToData(sToSend);
                dataSent(1:4)     = swapbytes(typecast(uint32(sToSend.ClientID), 'uint8'));
                dataSent(5:8)     = swapbytes(typecast(uint32(sToSend.ServerID), 'uint8'));
                dataSent(9:12)    = swapbytes(typecast(uint32(sToSend.PacketID), 'uint8'));
                dataSent(13:16)   = swapbytes(typecast(uint32(sToSend.ReplyToPacketID), 'uint8'));
                dataSent(17:24)   = swapbytes(typecast(uint64(sToSend.Timestamp), 'uint8'));
                dataSent(25:28)   = swapbytes(typecast(uint32(sToSend.RequestType), 'uint8'));
                dataSent(29:284)  = strToUnit8(obj, sToSend.FileName, 256);
                dataSent(285:348) = strToUnit8(obj, sToSend.FileName, 64);
                dataSent(349:412) = strToUnit8(obj, sToSend.FileName, 64);
                dataSent(413:416) = swapbytes(typecast(uint32(sToSend.Ovr), 'uint8'));
                


            % Send function packet
            fwrite(obj.udp_obj, dataSent);
            if (obj.flWaitReturn)
                % Get reply to sent packet
                dataReceived = uint8(fread(obj.udp_obj, 1024));

                % PARSING RETURN DATA
                sReceived = obj.dataToCommStruct(dataReceived);

                if (sReceived.RequestType ~= 10)                 % Type: RET_SMI_SAVE_RECORD
                    return;
                end
            end

            ret = 0;
        end
        
        function ret = SMIp_SendImageMessage( ...
                obj, ...
                Msg)
            
            ret = -1;
            if (~obj.flIsConnected)
                return;
            end
            
            % Format function packet
            sToSend = struct( ...
                'ClientID', 1, ...                          % Client ID
                'ServerID', 2, ...                          % Server ID
                'PacketID', 1, ...                          % Packet ID
                'ReplyToPacketID', 0, ...                   % Reply To Packet ID
                'Timestamp', todatenum(cdfepoch(now)), ...  % Time stamp
                'RequestType', 3, ...                       % Type: GET_SMI_SEND_MSG
                'Msg', Msg);

%             dataSent = obj.commStructToData(sToSend);
                dataSent(1:4)     = swapbytes(typecast(uint32(sToSend.ClientID), 'uint8'));
                dataSent(5:8)     = swapbytes(typecast(uint32(sToSend.ServerID), 'uint8'));
                dataSent(9:12)    = swapbytes(typecast(uint32(sToSend.PacketID), 'uint8'));
                dataSent(13:16)   = swapbytes(typecast(uint32(sToSend.ReplyToPacketID), 'uint8'));
                dataSent(17:24)   = swapbytes(typecast(uint64(sToSend.Timestamp), 'uint8'));
                dataSent(25:28)   = swapbytes(typecast(uint32(sToSend.RequestType), 'uint8'));
                dataSent(29:92)   = strToUnit8(obj, sToSend.Msg, 64);
                


            % Send function packet
            fwrite(obj.udp_obj, dataSent);
            if (obj.flWaitReturn)
                % Get reply to sent packet
                dataReceived = uint8(fread(obj.udp_obj, 1024));

                % PARSING RETURN DATA
                sReceived = obj.dataToCommStruct(dataReceived);

                if (sReceived.RequestType ~= 4)                 % Type: RET_SMI_SEND_MSG
                    return;
                end
            end

            ret = 0;
        end
        
    end
    
 	properties(Access = private)
        flIsConnected = false;
        flIsRecording = false;
        udp_obj = 0;
        flWaitReturn = true;
    end

    methods(Access = private)
        function ret = strToUnit8(obj, data, mlen)
           ret(1:mlen) = uint8(0);
           dlen = length(data);
           if (dlen >= mlen)
               return;
           end
           
           ret(1:dlen) = uint8(data);
        end
        
        
        function ret = bytesToInt(obj, data)
            ret = typecast(uint8(data(1:4)),'uint32');
        end

        function ret = dataToCommStruct(obj, data)
            ret = struct(...
                'ClientID', obj.bytesToInt(data(1:4)), ...
                'ServerID', obj.bytesToInt(data(5:8)), ...
                'PacketID', obj.bytesToInt(data(9:12)), ...
                'ReplyToPacketID', obj.bytesToInt(data(13:16)), ...
                'Timestamp', typecast(uint8(data(17:24)),'uint64'), ...
                'RequestType', obj.bytesToInt(data(25:28)), ...
                'Data', data(29:1024));
        end
        
        function ret = commStructToData(obj, sToSend)
        %COMMSTRUCTTODATA Turns a comm struct to char data that can 
        % be sent over UDP
            ret(1:4)     = swapbytes(typecast(uint32(sToSend.ClientID), 'uint8'));
            ret(5:8)     = swapbytes(typecast(uint32(sToSend.ServerID), 'uint8'));
            ret(9:12)    = swapbytes(typecast(uint32(sToSend.PacketID), 'uint8'));
            ret(13:16)   = swapbytes(typecast(uint32(sToSend.ReplyToPacketID), 'uint8'));
            ret(17:24)   = swapbytes(typecast(uint64(sToSend.Timestamp), 'uint8'));
            ret(25:28)   = swapbytes(typecast(uint32(sToSend.RequestType), 'uint8'));
            ret(29:1024) = sToSend.Data;
        end
    end

end