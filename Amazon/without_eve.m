function [circuit_Alice, circuit_Bob] = without_eve()
        
    h1 = hGate(1);
    rx2 = rxGate(2, pi/2);
    cx12 = cxGate(1, 2);
    rx1 = rxGate(1, pi/4);
    
    h3 = hGate(3);
    rx4 = rxGate(4, 2*pi/2);
    cx34 = cxGate(3, 4);
    rx3 = rxGate(3, 2*pi/4);
    
    h5 = hGate(5);
    rx6 = rxGate(6, 3*pi/2);
    cx56 = cxGate(5, 6);
    rx5 = rxGate(5, 3*pi/4);
    
    h7 = hGate(7);
    id8 = idGate(8);
    rx7 = rxGate(7, 4*pi/4);

    x1 = xGate(1);
    x2 = xGate(2);
    x3 = xGate(3);
    x4 = xGate(4);
    x5 = xGate(5);
    x6 = xGate(6);
    x7 = xGate(7);
    x8 = xGate(8);


    
    gates_Alice =[h1 cx12 rx2 rx1 h3 cx34 rx4 rx3 h5 cx56 rx6 rx5 h7 rx7 id8];
    gates_Bob =[h1 cx12 rx2 rx1 h3 cx34 rx4 rx3 h5 cx56 rx6 rx5 h7 rx7 id8 x1 x2 x3 x4 x5 x6 x7];
    
    circuit_Alice = quantumCircuit(gates_Alice, 8);
    circuit_Bob = quantumCircuit(gates_Bob, 8)

end