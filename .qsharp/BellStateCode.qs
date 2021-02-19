namespace Task2SampleTests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Core;
    open Task2;

    @EntryPoint()
    operation SampleTests(): Unit{

        // The measurement results are checked using different error gates for the two input qubit states. 
        // (Z0 , X0) means phase flip occurs for the first qubit of the first three-qubit register
        // and bit flip occurs for the second three-qubit register.
        // Id is the identity gate applied on the three-qubit register.
        let Z0 = ApplyPauli([PauliZ, PauliI, PauliI], _);
        let Z1 = ApplyPauli([PauliI, PauliZ, PauliI], _);
        let Z2 = ApplyPauli([PauliI, PauliI, PauliZ], _);
        let X0 = ApplyPauli([PauliX, PauliI, PauliI], _);
        let X1 = ApplyPauli([PauliI, PauliX, PauliI], _);
        let X2 = ApplyPauli([PauliI, PauliI, PauliX], _);
        let Id = ApplyPauli([PauliI, PauliI, PauliI], _);
         
        BellStateTestForError(Z0, X0);
        BellStateTestForError(Z2, X1);
        BellStateTestForError(Id, X2);
        BellStateTestForError(X2, Z1);
        BellStateTestForError(Z0, Id);
        Message("Test for the error gates passed.");
    }

    /// # Summary
    /// Checks whether measurement results of first and fourth qubit of the 6 qubit register are in line 
    /// with the expected measurement result of the Bell State ((|00〉 + |11〉)/sqrt(2)), 
    /// i.e., (Zero, Zero) or (One, One). 
    /// # Input
    /// ## Error1
    /// Error gate applied on the first 3 qubit register.
    /// Bit-flip error (X gate), sign-flip error (Z gate) or Identity gate.
    /// ## Error2
    /// Error gate applied on the second 3 qubit register.
    /// Bit-flip error (X gate), sign-flip error (Z gate) or Identity gate.

    operation BellStateTestForError(Error1 : Qubit[] => Unit, Error2 : Qubit[] => Unit) : Unit {
        let result = BellStateCode(Error1, Error2);
         // Asserts that a classical result has the expected value (One, One).
        if Fst(result)==One{
            EqualityFactR(Snd(result), One, "Expecting result One, received Zero"); 
        }
        // Asserts that a classical result has the expected value (Zero, Zero).
        else{
            EqualityFactR(Snd(result), Zero , "Expecting result Zero, received One");
        }
    }
}