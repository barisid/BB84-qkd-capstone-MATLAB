clear;
clc;
close all
%% Creating quantum circuit
circuit = with_eve
plot(circuit)

Key = '';
while length(convertStringsToChars(Key)) < 8
%% Generating a random input state

    numbers = [128:256];
    rand_Pos = randperm(length(numbers),1)
    selected = numbers(rand_Pos)
    selected = dec2bin(selected)
    zero = ['0' '+'];
    one = ['1', '-'];
    basis = '';
    Alice_basis = ''
    for q = 1:length(selected)
        if selected(q) == '1'
            rand_Pos_basis = randperm(2,1);
            selected_basis = one(rand_Pos_basis);
        else
            rand_Pos_basis = randperm(2,1);
            selected_basis = zero(rand_Pos_basis);
        end
        basis = append(basis,selected_basis);
        Alice_basis = append(Alice_basis, selected(q));
    end
    basis = convertCharsToStrings(basis);
    input_state = quantum.gate.QuantumState(basis)
    
    
    %% Simulation
    s = simulate(circuit, input_state)
    data = randsample(s, 100)
    table(data.Counts,data.MeasuredStates,VariableNames=["Counts","States"])
    figure
    histogram(data)
    grid on
    [K, I] = max(data.Counts);
    Bob_basis = data.MeasuredStates(I);
    Bob_basis = convertStringsToChars(Bob_basis);
    
    
    %% Comparing the bits

    for i = 1:8
                    % Checking if an 8-bit key is obtained or not
        if length(convertStringsToChars(Key)) == 8
            break;
            else
            % Receiving Bob's basis that he sended
            Bob_basis_bit = Bob_basis(i)
            % Comparing the Alice's basis with Bob's basis
            if Bob_basis_bit == Alice_basis(i)
                % If the basis is the same on the both side, then
                % add that bit to the Shared Key
                bit_state = "correct"
                Key = append(Key, Bob_basis_bit)
            else
                 % If the bases are not the same, then contine
                 % comparison 
                 bit_state = "wrong"
                 fprintf("An Eavesdropper is DETECTED!")
                 return
            end
        end
    end
end
