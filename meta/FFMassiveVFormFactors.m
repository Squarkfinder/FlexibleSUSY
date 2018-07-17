(* ::Package:: *)

(* :Copyright:

   ====================================================================
   This file is part of FlexibleSUSY.

   FlexibleSUSY is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published
   by the Free Software Foundation, either version 3 of the License,
   or (at your option) any later version.

   FlexibleSUSY is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with FlexibleSUSY.  If not, see
   <http://www.gnu.org/licenses/>.
   ====================================================================

*)

BeginPackage["FFMassiveVFormFactors`",
    {"SARAH`", "TextFormatting`", "TreeMasses`", "Vertices`", "CXXDiagrams`", "ColorMathInterface`"}
];

FFMassiveVFormFactorsCreateInterface::usage = "";
f::usage = "";
MassiveVIndices::usage = "";

Begin["Private`"];

MyVertex[particles_List] := MyVertex[particles] = SARAH`Vertex[particles];

MassiveVIndices[V_] :=
   Module[{name = CXXNameOfField[V], dim = TreeMasses`GetDimension[V]},
      (* we expect that the gauge group from which massive vector bosons come from is broken,
         i.e. there is no index *)
      Assert[dim === 1];

      "template<>\n" <>
      "typename field_indices<" <> name <> ">::type\n" <>
      "default_indices_for_spectator<" <> name <> "> (void)\n" <>
      "{\n" <>
         "return {};\n" <>
      "}\n"
   ];

FFMassiveVFormFactorsCreateInterface[inFermion_, outFermion_, spectator_, loopParticles_List] :=
    Module[{prototype, definition,
            numberOfIndices1 = CXXDiagrams`NumberOfFieldIndices[inFermion],
            numberOfIndices2 = CXXDiagrams`NumberOfFieldIndices[outFermion],
            numberOfIndices3 = CXXDiagrams`NumberOfFieldIndices[spectator]},

      prototype =
         "std::valarray<std::complex<double>> calculate_" <> CXXNameOfField[inFermion] <>
            "_" <> CXXNameOfField[outFermion] <> "_" <> CXXNameOfField[spectator] <> "_form_factors" <>
            " (\n" <>
            If[TreeMasses`GetDimension[inFermion] =!= 1,
               "   int generationIndex1, ",
               " "
            ] <>
            If[TreeMasses`GetDimension[outFermion] =!= 1,
               " int generationIndex2, ",
               " "
            ] <>
            "const " <> FlexibleSUSY`FSModelName <> "_mass_eigenstates& model )";

      definition =
          prototype <> "{\n" <>
            IndentText[
               FlexibleSUSY`FSModelName <> "_mass_eigenstates model_ = model;\n" <>
               "EvaluationContext context{ model_ };\n" <>
               "std::array<int, " <> ToString @ numberOfIndices1 <> "> indices1 = {" <>
                     (* TODO: Specify indices correctly *)
                       If[TreeMasses`GetDimension[inFermion] =!= 1,
                          " generationIndex1" <>
                          If[numberOfIndices1 =!= 1,
                             StringJoin @ Table[", 0", {numberOfIndices1-1}],
                             ""] <> " ",
                          If[numberOfIndices1 =!= 0,
                             StringJoin @ Riffle[Table[" 0", {numberOfIndices1}], ","] <> " ",
                             ""]
                         ] <> "};\n" <>
                   "std::array<int, " <> ToString @ numberOfIndices2 <>
                     "> indices2 = {" <>
                       If[TreeMasses`GetDimension[outFermion] =!= 1,
                          " generationIndex2" <>
                          If[numberOfIndices2 =!= 1,
                             StringJoin @ Table[", 0", {numberOfIndices2-1}],
                             ""] <> " ",
                          If[numberOfIndices2 =!= 0,
                             StringJoin @ Riffle[Table[" 0", {numberOfIndices2}], ","] <> " ",
                             ""]
                         ] <> "};\n\n" <>

               "std::valarray<std::complex<double>> val {0.0, 0.0};\n\n" <>

               StringJoin[
                  ("val += std::complex<double> {" <> (ToString @ N[#[[2,1]], 16]) <> "} * FFMassiveVVertexCorrectionFS<" <>
                   StringRiffle[CXXDiagrams`CXXNameOfField /@ {inFermion, outFermion, spectator, #[[1,1]], #[[1,2]]}, ","]  <>
                   ">::value(indices1, indices2, context);\n") & /@ loopParticles
               ] <> "\n" <>

               "return val;"

            ] <> "\n}\n\n";

    {prototype <> ";", definition}
  ];

(* if t is TreeMasses`IsScalar then returns list of scalars and anti-scalar, etc. *)
getParticlesOfType[t_] :=
    DeleteDuplicates@Join[#, CXXDiagrams`LorentzConjugate /@ #]& @
      Select[TreeMasses`GetParticles[], t];

vertexNonZero[vertex_] :=
    Transpose[Drop[vertex, 1]][[1]] =!= {0,0};

vertexNonZeroS[vertex_] :=
    Transpose[Drop[vertex, 1]][[1]] =!= {0};

VertexIsNonZeroQ[vertex_] :=
   Module[{},
      True
   ];

(* if a diagram exists, return a color factor and a list of particles in vertices, otherwise return an empty list *)
singleDiagram[inFermion_, outFermion_, spectator_, F_?TreeMasses`IsFermion, S_?TreeMasses`IsScalar] :=
   Module[{FBarFjSBar, FiBarFS, SBarSVBar, FBarFVBar, v1, v2, v3, v4,colorIndexAssociation, p},

      (* if the electric charge of an incomind particle doesn't equal to the sum of charges of outgoing ones,
         return an {} *)
      If[TreeMasses`GetElectricCharge[inFermion] =!= Plus @@ (TreeMasses`GetElectricCharge /@ {S,F}),
         Return[{}]
      ];

      colorIndexAssociation =
         If[TreeMasses`ColorChargedQ[#],
            If[TreeMasses`GetDimension[#] === 1,
               #[{Unique["ct"]}],
               #[{Unique["gt"], Unique["ct"]}]
            ], #
         ]& /@ {outFermion, F, S, F, S, inFermion, spectator};

      p = colorIndexAssociation;
      p = {p[[6]], p[[1]], p[[7]], p[[4]], p[[2]], p[[5]], p[[3]]};

      v1 = {CXXDiagrams`LorentzConjugate[F], inFermion, CXXDiagrams`LorentzConjugate[S]};
      FBarFjSBar = SARAHToColorMathSymbols@SARAH`Vertex[{CXXDiagrams`LorentzConjugate[p[[4]]], p[[1]], CXXDiagrams`LorentzConjugate[p[[6]]]}];
      v2 = {CXXDiagrams`LorentzConjugate[outFermion], F, S};
      FiBarFS = SARAHToColorMathSymbols@SARAH`Vertex[{CXXDiagrams`LorentzConjugate[p[[2]]], p[[5]], p[[7]]}];
      v3 = {CXXDiagrams`LorentzConjugate[S], S, CXXDiagrams`LorentzConjugate[spectator]};
      SBarSVBar = SARAHToColorMathSymbols@SARAH`Vertex[{CXXDiagrams`LorentzConjugate[p[[7]]], p[[6]], CXXDiagrams`LorentzConjugate[p[[3]]]}];
      v4 = {CXXDiagrams`LorentzConjugate[F], F, CXXDiagrams`LorentzConjugate[spectator]};
      FBarFVBar = SARAHToColorMathSymbols@SARAH`Vertex[{CXXDiagrams`LorentzConjugate[p[[5]]], p[[4]], CXXDiagrams`LorentzConjugate[p[[3]]]}];

      If[vertexNonZero[FBarFjSBar] && vertexNonZero[FiBarFS],
         If[vertexNonZeroS[SBarSVBar] && !vertexNonZero[FBarFVBar],
            Return[
               {StripSU3Generators[p[[1]], p[[2]], p[[3]], #]& /@ {
                  ColorMath`CSimplify[CalculateColorFactor[{FBarFjSBar, FiBarFS, SBarSVBar}] ConnectColorLines[p[[5]], p[[4]]]],
                  0
               }, {v1, v2, v3}}
            ]
         ];
         If[vertexNonZero[FBarFVBar] && !vertexNonZeroS[SBarSVBar],
            Return[
               {StripSU3Generators[p[[1]], p[[2]], p[[3]], #]& /@ {
                  0,
                  ColorMath`CSimplify[CalculateColorFactor[{FBarFjSBar, FiBarFS, FBarFVBar}] ConnectColorLines[p[[7]], p[[6]]]]},
                  {v1,v2, v4}
               }
            ]
         ];
         If[vertexNonZero[FBarFVBar] && vertexNonZeroS[SBarSVBar],
            Print["kurwa ", p[[1]], " ", p[[2]], " ", p[[3]], " ", p[[4]], " ", p[[6]], " ", StripSU3Generators[p[[1]], p[[2]], p[[3]], #]& /@
                     {ColorMath`CSimplify[CalculateColorFactor[{FBarFjSBar, FiBarFS, SBarSVBar}] ConnectColorLines[p[[5]], p[[4]]]],
               ColorMath`CSimplify[CalculateColorFactor[{FBarFjSBar, FiBarFS, FBarFVBar}] ConnectColorLines[p[[7]], p[[6]]]]}];
            Return[
               {
                  StripSU3Generators[p[[1]], p[[2]], p[[3]], #]& /@
                     {ColorMath`CSimplify[CalculateColorFactor[{FBarFjSBar, FiBarFS, SBarSVBar}] ConnectColorLines[p[[5]], p[[4]]]],
               ColorMath`CSimplify[CalculateColorFactor[{FBarFjSBar, FiBarFS, FBarFVBar}] ConnectColorLines[p[[7]], p[[6]]]]},
                  {v1, v2, v3, v4}}
            ]
         ],
         Return[{}]
      ];

      Return[{}];
   ];

StripSU3Generators[inP_, outP_, spec_, c_] :=
   Module[{},
      If[TreeMasses`ColorChargedQ[inP] && TreeMasses`ColorChargedQ[outP] && !TreeMasses`ColorChargedQ[spec],
         Return[
            Coefficient[c, ColorMath`delta @@ (GetFieldColorIndex /@ {outP, inP})]
         ]
      ];
      If[TreeMasses`ColorChargedQ[inP] && TreeMasses`ColorChargedQ[outP] && TreeMasses`ColorChargedQ[spec],
         Return[
            Coefficient[c, ColorMath`t[{GetFieldColorIndex[spec]}, GetFieldColorIndex[outP], GetFieldColorIndex[inP]]]
         ]
      ];
      c
   ];

(* for SU(3) *)
ColorN[expr_] :=
   expr /. ColorMath`Nc -> 3 /. ColorMath`TR -> 1/2;

(* connect color indices of field1 and field2 *)
ConnectColorLines[field1_, field2_] :=
   Module[{r1 = getColorRep[field1], r2 = getColorRep[field2]},
      Assert[r1 === r2];
      Switch[r1,
         S, 1,
         T, ColorMath`delta @@ (GetFieldColorIndex /@ {field1, field2}),
         O, ColorMath`Delta @@ (GetFieldColorIndex /@ {field1, field2}),
         _, Abort[]
      ]
   ];

f[inFermion_, outFermion_, spectator_] :=
   Module[{scalars, fermions, internalParticles = {}, temp},

      scalars = getParticlesOfType[TreeMasses`IsScalar];
      fermions = getParticlesOfType[TreeMasses`IsFermion];

      Map[
         (temp = singleDiagram[inFermion, outFermion, spectator, #[[1]], #[[2]]];
         If[temp =!= {},
            AppendTo[internalParticles, {#, temp}]
            ])&,
         Tuples[{fermions, scalars}]
      ];

      internalParticles
   ];

(* TODO: add other topologies? *)

End[];
EndPackage[];
