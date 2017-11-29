﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {

    operation OperationPowImpl<'T>(oracle : ('T => ()), power : Int, target : 'T)  : ()
    {
        body {
            for (idxApplication in 0..power - 1) {
                oracle(target);
            }
        }
    }

    operation OperationPowImplC<'T>(oracle : ('T => () : Controlled), power : Int, target : 'T)  : ()
    {
        body {
            for (idxApplication in 0..power - 1) {
                oracle(target);
            }
        }

        controlled auto
    }

    operation OperationPowImplA<'T>(oracle : ('T => () : Adjoint), power : Int, target : 'T)  : ()
    {
        body {
            for (idxApplication in 0..power - 1) {
                oracle(target);
            }
        }

        adjoint auto
    }

    operation OperationPowImplCA<'T>(oracle : ('T => () : Controlled, Adjoint), power : Int, target : 'T)  : ()
    {
        body {
            for (idxApplication in 0..power - 1) {
                oracle(target);
            }
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Given an operation representing a gate $U$, returns a new operation
    /// $U^m$ for a power $m$.
    ///
    /// ## oracle
    /// An operation $U$ representing the gate to be repeated.
    /// ## power
    /// The number of times that $U$ is to be repeated.
    ///
    /// # Output
    /// A new operation representing $U^m$, where $m = \texttt{power}$.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.operationpowc"
    /// - @"microsoft.quantum.canon.operationpowa"
    /// - @"microsoft.quantum.canon.operationpowca"
    function OperationPow<'T>(oracle : ('T => ()), power : Int)  : ('T => ())
    {
        return OperationPowImpl(oracle, power, _);
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowC<'T>(oracle : ('T => () : Controlled), power : Int)  : ('T => () : Controlled)
    {
        return OperationPowImplC(oracle, power, _);
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowA<'T>(oracle : ('T => () : Adjoint), power : Int)  : ('T => () : Adjoint)
    {
        return OperationPowImplA(oracle, power, _);
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.operationpow"
    function OperationPowCA<'T>(oracle : ('T => () : Controlled, Adjoint), power : Int)  : ('T => () : Controlled, Adjoint)
    {
        return OperationPowImplCA(oracle, power, _);
    }

}
