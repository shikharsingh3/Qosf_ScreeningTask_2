// Quantum Mentorship Program -- QOSF -- Screening Task
///////////////////////--Task2--///////////////////////

namespace Task2 {
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

// The Bell state (|00〉 + |11〉)/sqrt(2), which is a maximally entangled state, is created by initialising
// a two qubit input state to |00> and applying a Hadamard gate to the first qubit and a CNOT gate with 
// first qubit as control input and second qubit as target input. In this task, an error gate is added to
// each of the two qubits before the CNOT gate. The error can be a bit-flip error (X gate), sign-flip 
// error (Z gate) or an identity gate. Each of the two qubits are encoded using bit-flip or sign-flip code
// and are subsequently measured in the Z-basis. On measuring the first qubit for the state (|00〉 + |11〉)/sqrt(2), 
// the result of measuring the second qubit is guaranteed to yield the same value - '00' or '11'.
//
// The first qubit state |0> is encoded using only sign-flip code because after applying Hadamard gate, a sign-flip error
// would flip |+〉 to |-〉 but a bit-flip error would leave the state |+〉 unchanged. Similarly, the second qubit state |0〉 is encoded 
// using only bit-flip code because a sign-flip error would leave the state |0〉 unchanged. This eliminates the 
// implementation of Shor Code to both of the input qubit states. Hence, the problem is simplified to encoding the 
// first qubit state |+〉 as |+++〉 and the second qubit state |0〉 as |000〉. Now since the encoded states are only |+++〉
// and |000〉, the application of CNOTs during encoding for the sign-flip and bit-flip code is not required.

    /// # Summary
    /// Encodes into three-qubit phase-flip code by applying Hadamard gate to each of the qubits.
    /// Also used to recover the state in |0〉, |1〉 basis during recovery by applying inverse of Hadamard gate (also the Hadamard gate).
    /// # Input
    /// ## register
    /// The three-qubit quantum register to be encoded or recovered.
    operation Encoder(register : Qubit[]): Unit is Adj + Ctl {
        for i in 0..2{
            H(register[i]);     
        }
    }
    
    /// # Summary
    /// Recovers the qubit state (after applying Hadamard gate to each of the qubits-Encoder()) 
    /// using Clifford + T gate set.
    /// # Input
    /// ## register
    /// The qubit state to be decoded.
    operation Recover(register : Qubit[]): Unit is Adj + Ctl {
        CNOT(register[0], register[1]);
        CNOT(register[0], register[2]);
        CCNOT(register[1], register[2], register[0]);
    }

    /// # Summary
    /// For error gates on first and second qubit register, the operation returns the measurement result of the Bell State. The first and fourth
    /// qubits of the 6 qubit register are measured.
    /// # Input
    /// ## ErrorGate1
    /// Error gate applied on the first 3 qubit register. 
    /// Bit-flip error (X gate), sign-flip error (Z gate) or Identity gate.
    /// ## ErrorGate2
    /// Error gate applied on the second 3 qubit register.
    /// Bit-flip error (X gate), sign-flip error (Z gate) or Identity gate.
    /// # Output
    /// Measurement result on measuring first and fourth qubit of the register in the Z-basis.
    operation BellStateCode (ErrorGate1 :(Qubit[] => Unit), ErrorGate2 :(Qubit[] => Unit)): (Result,Result){
        
        // Allocating qubits to two quantum registers, one for each input qubit state. 
        use register1 = Qubit[3];
        use register2 = Qubit[3];
        
        /// Encoding ///
        // register1 |000〉 is encoded into |+++〉. 
        Encoder(register1);
        // register2 |000〉 is already encoded into |000〉.
        
        /// Error ///
        // An error is applied on the first register and the second register which can be X gate, Z gate or Identity gate.
        // Probabilty of error is small enough so that the probability of more than a single qubit being 
        // bit-flipped or sign-flipped is negligible.
        ErrorGate1(register1);
        ErrorGate2(register2);

        /// Recovery ///
        // register1 is decoded back into |0〉, |1〉 basis by applying inverse of Hadamard gate (also the Hadamard gate). 
        Encoder(register1);
        // Each input qubit state is recovered using Clifford + T gate set on register1 and register2.  
        Recover(register1);
        Recover(register2);
        
        let register = register1 + register2;
        H(register[0]); 
        CNOT(register[0], register[3]);
        // Bell state measurement in Z-basis.
        mutable value1 = M(register[0]);
        mutable value2 = M(register[3]);
        // Each qubit is initialised back to |0〉. 
        ResetAll(register);
        return (value1, value2);   
    }
}