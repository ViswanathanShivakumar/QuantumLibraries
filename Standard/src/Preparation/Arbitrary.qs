// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Preparation {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Returns an operation that prepares the given quantum state.
    ///
    /// The returned operation $U$ prepares an arbitrary quantum
    /// state $\ket{\psi}$ with positive coefficients $\alpha_j\ge 0$ from
    /// the $n$-qubit computational basis state $\ket{0...0}$.
    ///
    /// The action of U on a newly-allocated register is given by
    /// $$
    /// \begin{align}
    ///     U \ket{0\cdots 0} = \ket{\psi} = \frac{\sum_{j=0}^{2^n-1}\alpha_j \ket{j}}{\sqrt{\sum_{j=0}^{2^n-1}|\alpha_j|^2}}.
    /// \end{align}
    /// $$
    ///
    /// # Input
    /// ## coefficients
    /// Array of up to $2^n$ coefficients $\alpha_j$. The $j$th coefficient
    /// indexes the number state $\ket{j}$ encoded in little-endian format.
    ///
    /// # Output
    /// A state-preparation unitary operation $U$.
    ///
    /// # Remarks
    /// Negative input coefficients $\alpha_j < 0$ will be treated as though
    /// positive with value $|\alpha_j|$. `coefficients` will be padded with
    /// elements $\alpha_j = 0.0$ if fewer than $2^n$ are specified.
    ///
    /// ## Example
    /// The following snippet prepares the quantum state $\ket{\psi}=\sqrt{1/8}\ket{0}+\sqrt{7/8}\ket{2}$
    /// in the qubit register `qubitsLE`.
    /// ```qsharp
    /// let amplitudes = [Sqrt(0.125), 0.0, Sqrt(0.875), 0.0];
    /// let op = StatePreparationPositiveCoefficients(amplitudes);
    /// using (qubits = Qubit[2]) {
    ///     let qubitsLE = LittleEndian(qubits);
    ///     op(qubitsLE);
    /// }
    /// ```
    function StatePreparationPositiveCoefficients (coefficients : Double[])
    : (LittleEndian => Unit is Adj + Ctl) {
        let nCoefficients = Length(coefficients);
        mutable coefficientsComplexPolar = new ComplexPolar[nCoefficients];

        for (idx in 0 .. nCoefficients - 1) {
            set coefficientsComplexPolar w/= idx <- ComplexPolar(AbsD(coefficients[idx]), 0.0);
        }

        return PrepareArbitraryState(coefficientsComplexPolar, _);
    }

    /// # Summary
    /// Returns an operation that prepares a specific quantum state.
    ///
    /// The returned operation $U$ prepares an arbitrary quantum
    /// state $\ket{\psi}$ with complex coefficients $r_j e^{i t_j}$ from
    /// the $n$-qubit computational basis state $\ket{0...0}$.
    ///
    /// The action of U on a newly-allocated register is given by
    /// $$
    /// \begin{align}
    ///     U\ket{0...0}=\ket{\psi}=\frac{\sum_{j=0}^{2^n-1}r_j e^{i t_j}\ket{j}}{\sqrt{\sum_{j=0}^{2^n-1}|r_j|^2}}.
    /// \end{align}
    /// $$
    ///
    /// # Input
    /// ## coefficients
    /// Array of up to $2^n$ complex coefficients represented by their
    /// absolute value and phase $(r_j, t_j)$. The $j$th coefficient
    /// indexes the number state $\ket{j}$ encoded in little-endian format.
    ///
    /// # Output
    /// A state-preparation unitary operation $U$.
    ///
    /// # Remarks
    /// Negative input coefficients $r_j < 0$ will be treated as though
    /// positive with value $|r_j|$. `coefficients` will be padded with
    /// elements $(r_j, t_j) = (0.0, 0.0)$ if fewer than $2^n$ are
    /// specified.
    ///
    /// ## Example
    /// The following snippet prepares the quantum state
    /// $\ket{\psi} = e^{i 0.1} \sqrt{1 / 8} \ket{0} + \sqrt{7 / 8} \ket{2}$
    /// on the qubit register `qubitsLE`:
    /// ```qsharp
    /// let amplitudes = [Sqrt(0.125), 0.0, Sqrt(0.875), 0.0];
    /// let phases = [0.1, 0.0, 0.0, 0.0];
    /// let coefficients = Mapped(ComplexPolar, Zip(amplitudes, phases));
    /// let op = StatePreparationComplexCoefficients(coefficients);
    /// using (qubits = Qubit[2]) {
    ///     let qubitsLE = LittleEndian(qubits);
    ///     op(qubitsLE);
    /// }
    /// ```
    function StatePreparationComplexCoefficients (coefficients : ComplexPolar[]) : (LittleEndian => Unit is Adj + Ctl) {
        return PrepareArbitraryState(coefficients, _);
    }


    /// # Summary
    /// Given an expansion of an abitrary state in the computational basis,
    /// prepares that state on a register of qubits.
    ///
    /// # Description
    /// Given a register of qubits initially in the $n$-qubit
    /// the $n$-qubit number state $\ket{0}$ (using a little-endian encoding),
    /// prepares that register in the state
    /// $$
    /// \begin{align}
    ///     \ket{\psi} & = \frac{
    ///                        \sum_{j = 0}^{2^n - 1} r_j e^{i t_j} \ket{j}
    ///                    }{
    ///                        \sqrt{\sum_{j = 0}^{2^n - 1} |r_j|^2}
    ///                    },
    /// \end{align}
    /// $$
    /// where $\{r_j e^{i t_j}\}_{j = 0}^{2^n - 1}$ is a list of complex
    /// coefficients representing the state to be prepared.
    ///
    /// # Input
    /// ## coefficients
    /// An array of up to $2^n$ complex coefficients represented by their
    /// magnitude and phase $(r_j, t_j)$. The $j$th coefficient
    /// indexes the number state $\ket{j}$ encoded in little-endian format.
    ///
    /// ## qubits
    /// Qubit register encoding number states in little-endian format. This is
    /// expected to be initialized in the number state $\ket{0}$.
    ///
    /// # Remarks
    /// Negative input coefficients $r_j < 0$ will be treated as though
    /// positive with value $|r_j|$. If `coefficients` is shorter than $2^n$
    /// elements, this input will be padded with elements
    /// $(r_j, t_j) = (0.0, 0.0)$ (that is, elements representing the coefficient
    /// $0$).
    ///
    /// # Example
    /// The following snippet prepares a new three-qubit register in the state
    /// $\frac{1}{\sqrt{3}}\left( \sqrt{2} \ket{0} + e^{i \pi / 3} \ket{2} \right)$:
    ///
    /// ```Q#
    /// // Represent 1 / √3 (√2 |0⟩ + e^{𝑖 π / 3} |2⟩) as an array of complex
    /// // coefficients.
    /// let coefficients = [
    ///     ComplexPolar(Sqrt(2.0) / Sqrt(3.0), 0.0),
    ///     ComplexPolar(0.0, 0.0),
    ///     ComplexPolar(1.0 / Sqrt(3.0), PI() / 3.0)
    /// ];
    ///
    /// // Allocate a bare register of three qubits.
    /// using (qs = Qubit[3]) {
    ///     // Use the bare register to create a new little-endian register.
    ///     // Note that in a little-endian encoding, the computational basis
    ///     // state |000⟩ encodes the number state |0⟩.
    ///     let register = LittleEndian(qs);
    ///
    ///     // We can prepare the state represented by the coefficients array
    ///     // by calling PrepareArbitraryState.
    ///     PrepareArbitraryState(coefficients, register);
    ///     // ...
    /// }
    /// ```
    ///
    /// # References
    /// - Synthesis of Quantum Logic Circuits
    ///   Vivek V. Shende, Stephen S. Bullock, Igor L. Markov
    ///   https://arxiv.org/abs/quant-ph/0406176
    operation PrepareArbitraryState(coefficients : ComplexPolar[], qubits : LittleEndian)
    : Unit is Adj + Ctl {
        // pad coefficients at tail length to a power of 2.
        let paddedCoefficients = Padded(-2 ^ Length(qubits!), ComplexPolar(0.0, 0.0), coefficients);
        let target = (qubits!)[0];
        let op = (Adjoint _UnprepareArbitraryState(paddedCoefficients, _, _))(_, target);

        op(
            // Determine what controls to apply to `op`.
            Length(qubits!) > 1
            ? LittleEndian((qubits!)[1 .. Length(qubits!) - 1])
            | LittleEndian(new Qubit[0])
        );
    }


    /// # Summary
    /// Implementation step of arbitrary state preparation procedure.
    /// As it is easier to implement an operation that maps the given state
    /// to $\ket{0}$, we do that here in an adjointable manner, then take the
    /// adjoint to get the desired preparation.
    ///
    /// # See Also
    /// - PrepareArbitraryState
    /// - Microsoft.Quantum.Canon.MultiplexPauli
    operation _UnprepareArbitraryState(coefficients : ComplexPolar[], control : LittleEndian, target : Qubit)
    : Unit is Adj + Ctl {
        // For each 2D block, compute disentangling single-qubit rotation
        // parameters.
        let (disentanglingY, disentanglingZ, newCoefficients) = _StatePreparationSBMComputeCoefficients(coefficients);
        MultiplexPauli(disentanglingZ, PauliZ, control, target);
        MultiplexPauli(disentanglingY, PauliY, control, target);

        // At this point, by having applied the disentanglers above, the target
        // qubit is guaranteed to be in the |0⟩ state, up to a global phase
        // given by the argument of newCoefficients[0].
        // Since this operation may be called in a controlled fashion, we need
        // to correct that phase before recursing.

        // Continue recursion while there are control qubits.
        if (Length(control!) == 0) {
            Exp([PauliI], -(Head(newCoefficients))::Argument, [target]);
        } else {
            _UnprepareArbitraryState(
                newCoefficients,
                LittleEndian(Rest(control!)),
                Head(control!)
            );
        }
    }


    /// # Summary
    /// Computes the Bloch sphere coordinates for a single-qubit state.
    ///
    /// # Description
    /// Given two complex numbers $a_0$ and $a_1$ represent the single-qubit state,
    /// $a_0 \ket{0} + a_1 \ket{1}$, returns coordinates $r$, $t$, $phi$, and
    /// $\theta$ on the Bloch sphere such that
    /// $$
    /// \begin{align}
    ///     a_0 \ket{0} + a_1 \ket{1} & = r e^_{i t} \left(
    ///         e^{-i \phi / 2} \cos(\theta / 2) \ket{0} +
    ///         e^{ i \phi / 2} \sin(\theta / 2) \ket{1}
    ///     \right).
    /// \end{align}
    ///
    /// # Input
    /// ## a0
    /// Complex coefficient of state $\ket{0}$.
    /// ## a1
    /// Complex coefficient of state $\ket{1}$.
    ///
    /// # Output
    /// A tuple containing `(ComplexPolar(r, t), phi, theta)`.
    ///
    /// # Example
    /// ```Q#
    /// let coefficients = (
    ///     ComplexPolar(Sqrt(2.0) / Sqrt(3.0), 0.0),
    ///     ComplexPolar(1.0 / Sqrt(3.0), PI() / 3.0)
    /// );
    /// let blochSphereCoordinates = BlochSphereCoordinates(coefficients);
    /// Message($"{blochSphereCoordinates}");
    /// // Output:
    /// // (ComplexPolar((1, 0.5235987755982988)), 1.0471975511965976, 1.2309594173407747)
    /// ```
    function BlochSphereCoordinates (a0 : ComplexPolar, a1 : ComplexPolar)
    : (ComplexPolar, Double, Double) {
        let r = Sqrt(PowD(a0::Magnitude, 2.0) + PowD(a1::Magnitude, 2.0));
        let t = 0.5 * (a0::Argument + a1::Argument);
        let phi = a0::Argument - a1::Argument;
        let theta = 2.0 * ArcTan2(a0::Magnitude, a1::Magnitude);
        return (ComplexPolar(r, t), phi, theta);
    }

    /// # Summary
    /// Implementation step of arbitrary state preparation procedure.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Preparation.PrepareArbitraryState
    function _StatePreparationSBMComputeCoefficients (coefficients : ComplexPolar[])
    : (Double[], Double[], ComplexPolar[]) {
        mutable disentanglingZ = new Double[Length(coefficients) / 2];
        mutable disentanglingY = new Double[Length(coefficients) / 2];
        mutable newCoefficients = new ComplexPolar[Length(coefficients) / 2];

        for (idxCoeff in 0 .. 2 .. Length(coefficients) - 1) {
            let (rt, phi, theta) = BlochSphereCoordinates(coefficients[idxCoeff], coefficients[idxCoeff + 1]);
            set disentanglingZ w/= idxCoeff / 2 <- 0.5 * phi;
            set disentanglingY w/= idxCoeff / 2 <- 0.5 * theta;
            set newCoefficients w/= idxCoeff / 2 <- rt;
        }

        return (disentanglingY, disentanglingZ, newCoefficients);
    }

}


