clear
clc
close all

Bob = tcpclient("192.168.1.106", 80, "Timeout", 100)
Key = "";
writeline(Bob, "ready")
while length(convertStringsToChars(Key)) < 8
    ARNstr = readline(Bob)
    task = quantum.backend.QuantumTaskAWS(ARNstr)
    wait(task)
    data = fetchOutput(task);
    [K, I] = max(data.Counts);
        measurement = data.MeasuredStates(I)
        measurement = convertStringsToChars(measurement);
        % figure(1);
        % histogram(data);

    
        for i=1:8
            if length(convertStringsToChars(Key)) == 8 
                    break;
            end
            writeline(Bob, measurement(i));
            comparison = readline(Bob);
            if comparison == "correct"
                Key = append(Key, convertCharsToStrings(measurement(i)));
            end
        end
        Key
end
writeline(Bob, "Key is generated on Bob's side.")
readline(Bob)
flush(Bob)
while 1
    encrypted_message = readline(Bob);
    encrypted_message
    encrypted_message = convertStringsToChars(encrypted_message)
    decrypted_message = ""
    for q = 1:length(convertStringsToChars(encrypted_message))
        decrypted_char = todecimal(double(encrypted_message(q))) - bin2dec(Key);
        decrypted_message = append(decrypted_message, char(decrypted_char));
    end
    decrypted_message
    writeline(Bob, "Message received.")

    message = input("Type a message to send Alice: ", "s")
    encrypted_message = '';
    for q = 1:length(message)
        encrypted_char = char(todecimal(double(message(q))) + bin2dec(Key));
        encrypted_message = append(encrypted_message, encrypted_char);
    end
    encrypted_message
    writeline(Bob, encrypted_message)
end


