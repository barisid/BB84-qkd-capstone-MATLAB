clear;
clc;
close all
%% TCP/IP CONNECTION FOR CLASSICAL CHANNEL
system('ipconfig')
% specifying the IPv4 address
ip_address = "192.168.1.106"
port = 80
server = tcpserver(ip_address, port, 'Timeout', 100)

fprintf('Waiting for Bob to connect...\n')
tic
pause(6)
toc
server

%% SETTING AMAZON BRAKET SV1 DEVICE FOR SIMULATION
reg = "eu-west-2";
bucketPath = 's3://amazon-braket-qkd-capstone/BB84/';
device = quantum.backend.QuantumDeviceAWS("arn:aws:braket:::device/quantum-simulator/amazon/sv1",Region=reg, S3Path=bucketPath)
fetchDetails(device)
Key = '';
total_circuit_runs = 0;
status = readline(server)

% Getting quantum circuits for Alice and Bob
[Alice_circuit, Bob_circuit] = without_eve;
figure
plot(Alice_circuit)
figure
plot(Bob_circuit)

%% KEY GENERATION
if status == "ready"
    t_start = tic
    % Looping "Key Generation" Sequence until an 8-bit key is generated on
    % both sides.
    while length(convertStringsToChars(Key)) < 8

        % Running Simulation on Amazon Braket
        task_Alice = run(Alice_circuit, device, 'NumShots',100);
        task_Bob = run(Bob_circuit, device, "NumShots", 100)
        wait(task_Alice);
        
        % Amazon S3 Bucket address for making Bob to be able to fetch
        % outputs
        ARNstr = task_Bob.TaskARN;
        
        % Counting how many times this sequence is ran to generate an 8-bit
        % key
        total_circuit_runs = total_circuit_runs + 1;
        
        % Sending the S3 Bucket address to Bob
        writeline(server, ARNstr);

        % Alice's measurements
        Alice_data = fetchOutput(task_Alice);
        
        % Find which bit sequence has the highest probability
        [K, I] = max(Alice_data.Counts);
        Alice_basis = Alice_data.MeasuredStates(I);
        Alice_basis = convertStringsToChars(Alice_basis);
        
        % Wait for Bob to have his measurements
        tic
        pause(10)
        toc
            
        % Iterating through bit sequence
            for i = 1:8
                % Checking if an 8-bit key is obtained or not
                if length(convertStringsToChars(Key)) == 8
                    break;
                else
                    % Receiving Bob's basis that he sended
                    Bob_basis = readline(server)
                    % Comparing the Alice's basis with Bob's basis
                    if Bob_basis == Alice_basis(i)
                        % If the basis is the same on the both side, then
                        % add that bit to the Shared Key
                        bit_state = "correct"
                        Key = append(Key, Bob_basis)
                        writeline(server, bit_state)
                    else
                        % If the bases are not the same, then contine
                        % comparison 
                        bit_state = "wrong"
                        writeline(server, bit_state)
                    end
                end

            end
        
    end
    flush(server)
end
readline(server)
writeline(server, "Key is generated on the Alice's side.")
t_end = toc(t_start);
tic
pause(10)
toc
flush(server)

%% Real-time chatting between Alice and Bob
while 1
    
%% ALICE SENDS A MESSAGE TO BOB
    message = input("to Bob:/n", "s")
    encrypted_message = '';
    for q = 1:length(message)    
       encrypted_char = char(todecimal(double(message(q))) + bin2dec(Key));
       encrypted_message = append(encrypted_message, encrypted_char);
    end
    encrypted_message
    writeline(server, char(encrypted_message))

    readline(server)
    flush(server)

%% ALICE RECEIVING A MESSAGE FROM BOB
    encrypted_message = readline(server);
    encrypted_message
    decrypted_message = ''
    encrypted_message = convertStringsToChars(encrypted_message)
    for q = 1:length(encrypted_message)
        decrypted_char = char(todecimal(double(encrypted_message(q)))- bin2dec(Key));
        decrypted_message = append(decrypted_message, decrypted_char);
    end
    fprintf("from Bob:/n")
    fprintf(decrypted_message)
end



    