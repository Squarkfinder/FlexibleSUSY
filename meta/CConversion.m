
BeginPackage["CConversion`", {"SARAH`", "TextFormatting`", "Utils`"}];

TensorType::usage="";
MatrixType::usage="";
ArrayType::usage="";
VectorType::usage="";
ScalarType::usage="";
ChiralitySum::usage="";

integerScalarCType::usage="represents an integer C type";
realScalarCType::usage="represents a real scalar C type";
complexScalarCType::usage="represents a complex scalar C type";

ToRealType::usage="converts a given type to a type with real elements";

IsRealType::usage="Returns true if given type has real elements";

GreekQ::usage = "Returns true if the given symbol contains one or more
 greek letters.";

UNITMATRIX::usage="";
ZEROARRAY::usage="";
ZEROMATRIX::usage="";
ZEROTENSOR::usage="";
ZEROVECTOR::usage="";
UNITMATRIXCOMPLEX::usage="";
ZEROARRAYCOMPLEX::usage="";
ZEROMATRIXCOMPLEX::usage="";
ZEROTENSORCOMPLEX::usage="";
ZEROVECTORCOMPLEX::usage="";
PROJECTOR::usage="";
oneOver16PiSqr::usage="";
twoLoop::usage="";
threeLoop::usage="";
Sqr::usage="";
AbsSqr::usage="";
AbsSqrt::usage="";
FSKroneckerDelta::usage="";
TensorProd::usage="";
UVec::usage="unit vector";
UMat::usage="matrix projector";
Eval::usage="calls .eval()";
PS::usage="scalar projector";

HaveSameDimension::usage = "Checks if given types have same
dimension";

CountNumberOfEntries::usage = "returns numbers of entries of a
 given type";

CreateCType::usage="returns string with the C/C++ data type";

GetElementType::usage="returns type of matrix / vector / array elements";

GetScalarElementType::usage="returns a ScalarType whose element type
is equal to the element type from the given type"

CastTo::usage="cast an (string) expression to a give type";

ToValidCSymbol::usage="creates a valid C variable name from a symbol";

ToValidCSymbolString::usage="returns the result of ToValidCSymbol[] as
a string";

RValueToCFormString::usage="converts a Mathematica expression to a C
expression.";

GetHead::usage="returns the head of a symbol
GetHead[s]        ->  s
GetHead[s[a]]     ->  s
GetHead[s[a][b]]  ->  s";

CreateUnitMatrix::usage="creates a unit matrix for a given parameter
type";

CreateZero::usage="creates a zero matrix for a given parameter
type";

CreateGetterPrototype::usage="creates C/C++ getter prototype";

CreateInlineSetter::usage="creates C/C++ inline setter"
CreateInlineElementSetter::usage="creates C/C++ inline setter for a
vector or matrix element";
CreateInlineSetters::usage="creates a C/C++ inline setter, and, if
given a vector or matrix, a C/C++ inline setter for a singlet element";

CreateInlineGetter::usage="creates C/C++ inline getter"
CreateInlineElementGetter::usage="creates C/C++ inline getter for a
vector or matrix element";
CreateInlineGetters::usage="creates a C/C++ inline getter, and, if
given a vector or matrix, a C/C++ inline getter for a single element";

CreateGetterReturnType::usage="creates C/C++ getter return type";

CreateDefaultAggregateInitialization::usage = "creates C/C++ default
aggregate initialization for a given parameter type";

CreateDefaultConstructor::usage="creates C/C++ default constructor for
a given parameter type";

CreateDefaultDefinition::usage="creates C/C++ variable definition
using the default constructor";

CreateConstExternDecl::usage="";
CreateConstDef::usage="";

SetToDefault::usage="set parameter to default value";

MakeUnique::usage="create a unique symbol from a string";

ProtectTensorProducts::usage="";

ReleaseHoldAt::usage="Release a Hold-ed expression at a specified
level.

Example:

  In[]:= expr = Hold[Plus[Plus[2, 2], 2]];
  In[]:= ReleaseHoldAt[expr, {1, 1}]
  Out[]= Hold[4 + 2]

Taken from:

  https://stackoverflow.com/questions/3136604/evaluate-beyond-one-level-within-hold-in-mathematica
";

RefactorSums::usage="Rewrite nested SARAH`sum[] such that loop
functions are called less frequently.

Note: The the cost function FunctionCost[] must be defined for the
loop functions.";

{ Sqr, Cube, Quad, Power2, Power3, Power4, Power5, Power6, Power7, Power8 };

Begin["`Private`"];

ReleaseHoldAt[expr_, partspec_] :=
    ReplacePart[expr, partspec -> Extract[expr, partspec]]

(* This rule is essential for the ExpandSums[] function.
 * It prevents the following bug:
 *
 *   In[]:= expr = Power[ThetaStep[i1,5],2];
 *   In[]:= DeleteCases[expr, ThetaStep[_,_]]
 *   Out[]= 2
 *)
SARAH`ThetaStep /: Power[SARAH`ThetaStep[a_,b_],_] := SARAH`ThetaStep[a,b];

GetElementType[CConversion`ScalarType[type_]]     := type;
GetElementType[CConversion`ArrayType[type_, __]]  := type;
GetElementType[CConversion`VectorType[type_, __]] := type;
GetElementType[CConversion`MatrixType[type_, __]] := type;
GetElementType[CConversion`TensorType[type_, __]] := type;

GetScalarElementType[CConversion`ChiralitySum[type_]] :=
    CConversion`ChiralitySum[GetScalarElementType[type]];

GetScalarElementType[type_] :=
    CConversion`ScalarType[GetElementType[type]];

(* better use TensorFixedSize class *)
EigenTensor[elementType_String, dim1_String, dim2_String, dim3_String] :=
    "Eigen::Tensor<" <> elementType <> ", 3>";

(* better use TensorFixedSize class *)
EigenTensor[elementType_String, dim1_String, dim2_String, dim3_String, dim4_String] :=
    "Eigen::Tensor<" <> elementType <> ", 4>";

EigenMatrix[elementType_String, dim1_String, dim2_String] :=
    "Eigen::Matrix<" <> elementType <> "," <> dim1 <> "," <> dim2 <> ">";

EigenMatrix[elementType_String, dim_String] :=
    "Eigen::Matrix<" <> elementType <> "," <> dim <> "," <> dim <> ">";

EigenArray[elementType_String, dim1_String, dim2_String] :=
    "Eigen::Array<" <> elementType <> "," <> dim1 <> "," <> dim2 <> ">";

EigenArray[elementType_String, dim_String] :=
    "Eigen::Array<" <> elementType <> "," <> dim <> ",1>";

EigenVector[elementType_String, dim_String] :=
    "Eigen::Matrix<" <> elementType <> "," <> dim <> ",1>";

ToRealType[CConversion`ScalarType[_]] := CConversion`ScalarType[realScalarCType];
ToRealType[CConversion`ArrayType[_,n_]] := CConversion`ArrayType[realScalarCType, n];
ToRealType[CConversion`VectorType[_,n_]] := CConversion`VectorType[realScalarCType, n];
ToRealType[CConversion`MatrixType[_,m_,n_]] := CConversion`MatrixType[realScalarCType, m, n];
ToRealType[CConversion`TensorType[_,n__]] := CConversion`TensorType[realScalarCType, n];

IsRealType[_[CConversion`realScalarCType, ___]] := True;
IsRealType[_[CConversion`integerScalarCType, ___]] := True;
IsRealType[_] := False;

CreateCType[type_] :=
    Print["Error: CreateCType: unknown type: " <> ToString[type]];

CreateCType[CConversion`ScalarType[integerScalarCType]] :=
    "int";

CreateCType[CConversion`ScalarType[realScalarCType]] :=
    "double";

CreateCType[CConversion`ScalarType[complexScalarCType]] :=
    "std::complex<" <> CreateCType[CConversion`ScalarType[realScalarCType]] <> ">";

CreateCType[CConversion`ArrayType[t_, entries_]] :=
    EigenArray[CreateCType[ScalarType[t]], ToString[entries]];

CreateCType[CConversion`VectorType[t_, entries_]] :=
    EigenVector[CreateCType[ScalarType[t]], ToString[entries]];

CreateCType[CConversion`MatrixType[t_, dim1_, dim2_]] :=
    EigenMatrix[CreateCType[ScalarType[t]], ToString[dim1], ToString[dim2]];

CreateCType[CConversion`TensorType[t_, dims__]] :=
    EigenTensor[CreateCType[ScalarType[t]], Sequence @@ (ToString /@ {dims})];

CreateCType[CConversion`ChiralitySum[type_]] :=
    "LRS_tensor<" <> CreateCType[type] <> ">";

CastTo[expr_String, toType_ /; toType === None] := expr;

CastTo[expr_String, toType_] :=
    Switch[toType,
           CConversion`ScalarType[CConversion`realScalarCType],
           "Re(" <> expr <> ")"
           ,
           CConversion`VectorType[CConversion`realScalarCType,_] |
           CConversion`ArrayType[ CConversion`realScalarCType,_] |
           CConversion`MatrixType[CConversion`realScalarCType,__]|
           CConversion`TensorType[CConversion`realScalarCType,__],
           "(" <> expr <> ").real()"
           ,
           CConversion`ScalarType[CConversion`complexScalarCType],
           expr
           ,
           CConversion`VectorType[CConversion`complexScalarCType,_] |
           CConversion`ArrayType[ CConversion`complexScalarCType,_] |
           CConversion`MatrixType[CConversion`complexScalarCType,__]|
           CConversion`TensorType[CConversion`complexScalarCType,__],
           "(" <> expr <> ").cast<" <> CreateCType[CConversion`ScalarType[complexScalarCType]] <> " >()"
           ,
           _,
           Print["Error: CastTo: cannot cast expression ", expr, " to ", toType];
           ""
          ];

CreateGetterReturnType[type_] :=
    Print["Error: CreateGetterReturnType: unknown type: " <> ToString[type]];

CreateGetterReturnType[CConversion`ScalarType[type_]] :=
    CreateCType[CConversion`ScalarType[type]];

CreateGetterReturnType[CConversion`ArrayType[type_, entries_]] :=
    "const " <> CreateCType[CConversion`ArrayType[type, entries]] <> "&";

CreateGetterReturnType[CConversion`VectorType[type_, entries_]] :=
    "const " <> CreateCType[CConversion`VectorType[type, entries]] <> "&";

CreateGetterReturnType[CConversion`MatrixType[type_, dim1_, dim2_]] :=
    "const " <> CreateCType[CConversion`MatrixType[type, dim1, dim2]] <> "&";

CreateGetterReturnType[CConversion`TensorType[type_, dims__]] :=
    "const " <> CreateCType[CConversion`TensorType[type, dims]] <> "&";

CreateSetterInputType[type_] :=
    CreateGetterReturnType[type];

(* Creates a C++ inline element setter *)
CreateInlineElementSetter[parameter_String, elementType_String, dim_Integer] :=
    "void set_" <> parameter <> "(int i, " <> elementType <>
    " value) { " <> parameter <> "(i) = value; }\n";

CreateInlineElementSetter[parameter_String, elementType_String, dim1_Integer, dim2_Integer] :=
    "void set_" <> parameter <> "(int i, int k, " <> elementType <>
    " value) { " <> parameter <> "(i,k) = value; }\n";

CreateInlineElementSetter[parameter_String, elementType_String, dim1_Integer, dim2_Integer, dim3_Integer] :=
    "void set_" <> parameter <> "(int i, int k, int l, " <> elementType <>
    " value) { " <> parameter <> "(i,k,l) = value; }\n";

CreateInlineElementSetter[parameter_String, elementType_String, dim1_Integer, dim2_Integer, dim3_Integer, dim4_Integer] :=
    "void set_" <> parameter <> "(int i, int k, int l, int j, " <> elementType <>
    " value) { " <> parameter <> "(i,k,l,j) = value; }\n";

CreateInlineElementSetter[parameter_String, CConversion`ArrayType[t_, entries_]] :=
    CreateInlineElementSetter[parameter, "const " <> CreateCType[ScalarType[t]] <> "&", entries];

CreateInlineElementSetter[parameter_String, CConversion`VectorType[t_, entries_]] :=
    CreateInlineElementSetter[parameter, "const " <> CreateCType[ScalarType[t]] <> "&", entries];

CreateInlineElementSetter[parameter_String, CConversion`MatrixType[t_, dim1_, dim2_]] :=
    CreateInlineElementSetter[parameter, "const " <> CreateCType[ScalarType[t]] <> "&", dim1, dim2];

CreateInlineElementSetter[parameter_String, CConversion`TensorType[t_, dims__]] :=
    CreateInlineElementSetter[parameter, "const " <> CreateCType[ScalarType[t]] <> "&", dims];

(* Creates a C++ setter *)
CreateInlineSetter[parameter_String, type_String] :=
    "void set_" <> parameter <> "(" <> type <>
    " " <> parameter <> "_) { " <> parameter <> " = " <>
    parameter <> "_; }\n";

CreateInlineSetter[parameter_String, type_] :=
    CreateInlineSetter[parameter, CreateSetterInputType[type]];

CreateInlineSetters[parameter_String, type_] :=
    If[MatchQ[type, ScalarType[_]],
       CreateInlineSetter[parameter, type],
       CreateInlineSetter[parameter, type] <> CreateInlineElementSetter[parameter, type]
      ];

(* Creates a C++ inline element getter *)
CreateInlineElementGetter[parameter_String, elementType_String, dim_Integer, postFix_String:"", wrapper_String:""] :=
    elementType <> " get_" <> parameter <> postFix <> "(int i) const" <>
    " { return " <> If[wrapper != "", wrapper <> "(", ""] <> parameter <> "(i)" <> If[wrapper != "", ")", ""] <> "; }\n";

CreateInlineElementGetter[parameter_String, elementType_String, dim1_Integer, dim2_Integer, postFix_String:"", wrapper_String:""] :=
    elementType <> " get_" <> parameter <> postFix <> "(int i, int k) const" <>
    " { return " <> If[wrapper != "", wrapper <> "(", ""] <> parameter <> "(i,k)" <> If[wrapper != "", ")", ""] <> "; }\n";

CreateInlineElementGetter[parameter_String, elementType_String, dim1_Integer, dim2_Integer, dim3_Integer, postFix_String:"", wrapper_String:""] :=
    elementType <> " get_" <> parameter <> postFix <> "(int i, int k, int l) const" <>
    " { return " <> If[wrapper != "", wrapper <> "(", ""] <> parameter <> "(i,k,l)" <> If[wrapper != "", ")", ""] <> "; }\n";

CreateInlineElementGetter[parameter_String, elementType_String, dim1_Integer, dim2_Integer, dim3_Integer, dim4_Integer, postFix_String:"", wrapper_String:""] :=
    elementType <> " get_" <> parameter <> postFix <> "(int i, int k, int l, int j) const" <>
    " { return " <> If[wrapper != "", wrapper <> "(", ""] <> parameter <> "(i,k,l,j)" <> If[wrapper != "", ")", ""] <> "; }\n";

CreateInlineElementGetter[parameter_String, CConversion`ScalarType[t_], postFix_String:"", wrapper_String:""] :=
    CreateInlineGetter[parameter, CreateCType[ScalarType[t]], postFix, wrapper];

CreateInlineElementGetter[parameter_String, CConversion`ArrayType[t_, entries_], postFix_String:"", wrapper_String:""] :=
    CreateInlineElementGetter[parameter, CreateCType[ScalarType[t]], entries, postFix, wrapper];

CreateInlineElementGetter[parameter_String, CConversion`VectorType[t_, entries_], postFix_String:"", wrapper_String:""] :=
    CreateInlineElementGetter[parameter, CreateCType[ScalarType[t]], entries, postFix, wrapper];

CreateInlineElementGetter[parameter_String, CConversion`MatrixType[t_, dim1_, dim2_], postFix_String:"", wrapper_String:""] :=
    CreateInlineElementGetter[parameter, CreateCType[ScalarType[t]], dim1, dim2, postFix, wrapper];

CreateInlineElementGetter[parameter_String, CConversion`TensorType[t_, dims__], postFix_String:"", wrapper_String:""] :=
    CreateInlineElementGetter[parameter, CreateCType[ScalarType[t]], dims, postFix, wrapper];

(* Creates a C++ inline getter *)
CreateInlineGetter[parameter_String, type_String, postFix_String:"", wrapper_String:""] :=
    type <> " get_" <> parameter <> postFix <>
    "() const { return " <> If[wrapper != "", wrapper <> "(", ""] <> parameter <> If[wrapper != "", ")", ""] <> "; }\n";

CreateInlineGetter[parameter_String, type_, postFix_String:"", wrapper_String:""] :=
    CreateInlineGetter[ToValidCSymbolString[parameter], CreateGetterReturnType[type], postFix, wrapper];

CreateInlineGetters[parameter_String, type_, postFix_String:"", wrapper_String:""] :=
    If[MatchQ[type, ScalarType[_]],
       CreateInlineGetter[parameter, type, postFix, wrapper],
       CreateInlineGetter[parameter, type, postFix, wrapper] <> CreateInlineElementGetter[parameter, type, postFix, wrapper]
      ];

(* Creates C++ getter prototype *)
CreateGetterPrototype[parameter_String, type_String] :=
    type <> " get_" <> parameter <> "() const;\n";

CreateGetterPrototype[parameter_, type_] :=
    CreateGetterPrototype[parameter, CreateGetterReturnType[type]];

(* create default constructor initialization list *)
CreateDefaultConstructor[parameter_, type_] :=
    Block[{},
          Print["Error: unknown parameter type: " <> ToString[type]];
          Return[""];
         ];

CreateDefaultConstructor[parameter_String, CConversion`ScalarType[_]] :=
    parameter <> "(0)";

CreateDefaultConstructor[parameter_String, CConversion`ArrayType[type_, entries_]] :=
    parameter <> "(" <> CreateCType[CConversion`ArrayType[type, entries]] <> "::Zero())";

CreateDefaultConstructor[parameter_String, CConversion`VectorType[type_, entries_]] :=
    parameter <> "(" <> CreateCType[CConversion`VectorType[type, entries]] <> "::Zero())";

CreateDefaultConstructor[parameter_String, CConversion`MatrixType[type_, rows_, cols_]] :=
    parameter <> "(" <> CreateCType[CConversion`MatrixType[type, rows, cols]] <> "::Zero())";

CreateDefaultConstructor[parameter_String, CConversion`TensorType[type_, dims__]] :=
    parameter <> "(" <> CreateCType[CConversion`TensorType[type, dims]] <> "::Zero())";

CreateDefaultAggregateInitialization[type_] :=
    Block[{},
          Print["Error: unknown parameter type: " <> ToString[type]];
          Return[""];
         ];

CreateDefaultAggregateInitialization[CConversion`ScalarType[_]] := "{}";

CreateDefaultAggregateInitialization[t:(CConversion`ArrayType|CConversion`VectorType|CConversion`MatrixType|CConversion`TensorType)[__]] :=
    "{" <> CreateCType[t] <> "::Zero()}";

CreateDefaultDefinition[parameter_, type_] :=
    Print["Error: unknown parameter type: " <> ToString[type]];

CreateDefaultDefinition[parameter_String, CConversion`ScalarType[type_]] :=
    CreateCType[CConversion`ScalarType[type]] <> " " <> parameter <> " = 0";

CreateDefaultDefinition[parameter_String, CConversion`ArrayType[type_, entries_]] :=
    CreateCType[CConversion`ArrayType[type, entries]] <> " " <> parameter;

CreateDefaultDefinition[parameter_String, CConversion`VectorType[type_, entries_]] :=
    CreateCType[CConversion`VectorType[type, entries]] <> " " <> parameter;

CreateDefaultDefinition[parameter_String, CConversion`MatrixType[type_, rows_, cols_]] :=
    CreateCType[CConversion`MatrixType[type, rows, cols]] <> " " <> parameter;

CreateDefaultDefinition[parameter_String, CConversion`TensorType[type_, dims__]] :=
    CreateCType[CConversion`TensorType[type, dims]] <> " " <> parameter;

SetToDefault[parameter_, type_] :=
    Print["Error: unknown parameter type: " <> ToString[type]];

SetToDefault[parameter_String, CConversion`ScalarType[integerScalarCType]] :=
    parameter <> " = 0;\n";

SetToDefault[parameter_String, CConversion`ScalarType[realScalarCType]] :=
    parameter <> " = 0.;\n";

SetToDefault[parameter_String, CConversion`ScalarType[complexScalarCType]] :=
    parameter <> " = " <> CreateCType[CConversion`ScalarType[complexScalarCType]] <> "(0.,0.);\n";

SetToDefault[parameter_String, CConversion`ArrayType[type_, entries_]] :=
    parameter <> " = " <> CreateCType[CConversion`ArrayType[type, entries]] <> "::Zero();\n";

SetToDefault[parameter_String, CConversion`VectorType[type_, entries_]] :=
    parameter <> " = " <> CreateCType[CConversion`VectorType[type, entries]] <> "::Zero();\n";

SetToDefault[parameter_String, CConversion`MatrixType[type_, rows_, cols_]] :=
    parameter <> " = " <> CreateCType[CConversion`MatrixType[type, rows, cols]] <> "::Zero();\n";

SetToDefault[parameter_String, CConversion`TensorType[type_, dims__]] :=
    parameter <> " = " <> CreateCType[CConversion`TensorType[type, dims]] <> "::Zero();\n";

(* create unitary matrix *)
CreateUnitMatrix[type_] :=
    Block[{},
          Print["Error: CreateUnitMatrix: can't create unity matrix for type: ", type];
          Quit[1];
         ];

CreateUnitMatrix[CConversion`ScalarType[_]] := 1;

CreateUnitMatrix[CConversion`ArrayType[__]] := 1;

CreateUnitMatrix[CConversion`VectorType[__]] := 1;

CreateUnitMatrix[CConversion`MatrixType[CConversion`realScalarCType, rows_, rows_]] :=
    CConversion`UNITMATRIX[rows];

CreateUnitMatrix[CConversion`MatrixType[CConversion`complexScalarCType, rows_, rows_]] :=
    CConversion`UNITMATRIXCOMPLEX[rows];

CreateUnitMatrix[CConversion`TensorType[CConversion`realScalarCType, rows_, rows_, rows_]] :=
    CConversion`UNITTENSOR[rows,rows,rows];

CreateUnitMatrix[CConversion`TensorType[CConversion`complexScalarCType, rows_, rows_, rows_]] :=
    CConversion`UNITTENSORCOMPLEX[rows,rows,rows];

CreateUnitMatrix[CConversion`TensorType[CConversion`realScalarCType, rows_, rows_, rows_, rows_]] :=
    CConversion`UNITTENSOR[rows,rows,rows,rows];

CreateUnitMatrix[CConversion`TensorType[CConversion`complexScalarCType, rows_, rows_, rows_, rows_]] :=
    CConversion`UNITTENSORCOMPLEX[rows,rows,rows,rows];

CreateZero[type_] :=
    Block[{},
          Print["Error: CreateZero: can't create zero for type: ", type];
          Quit[1];
         ];

CreateZero[CConversion`ScalarType[_]] := 0;

CreateZero[CConversion`ArrayType[CConversion`realScalarCType, entries_]] :=
    CConversion`ZEROARRAY[entries];

CreateZero[CConversion`VectorType[CConversion`realScalarCType, entries_]] :=
    CConversion`ZEROVECTOR[entries];

CreateZero[CConversion`MatrixType[CConversion`realScalarCType, rows_, cols_]] :=
    CConversion`ZEROMATRIX[rows,cols];

CreateZero[CConversion`TensorType[CConversion`realScalarCType, dim1_, dim2_, dim3_]] :=
    CConversion`ZEROTENSOR3[dim1,dim2,dim3];

CreateZero[CConversion`TensorType[CConversion`realScalarCType, dim1_, dim2_, dim3_, dim4_]] :=
    CConversion`ZEROTENSOR4[dim1,dim2,dim3,dim4];

CreateZero[CConversion`ArrayType[CConversion`complexScalarCType, entries_]] :=
    CConversion`ZEROARRAYCOMPLEX[entries];

CreateZero[CConversion`VectorType[CConversion`complexScalarCType, entries_]] :=
    CConversion`ZEROVECTORCOMPLEX[entries];

CreateZero[CConversion`MatrixType[CConversion`complexScalarCType, rows_, cols_]] :=
    CConversion`ZEROMATRIXCOMPLEX[rows,cols];

CreateZero[CConversion`TensorType[CConversion`complexScalarCType, dim1_, dim2_, dim3_]] :=
    CConversion`ZEROTENSOR3COMPLEX[dim1,dim2,dim3];

CreateZero[CConversion`TensorType[CConversion`complexScalarCType, dim1_, dim2_, dim3_, dim4_]] :=
    CConversion`ZEROTENSOR4COMPLEX[dim1,dim2,dim3,dim4];

CreateConstExternDecl[parameter_String, type_] :=
    "extern const " <> CreateCType[type] <> " " <>
    parameter <> ";\n";

CreateConstExternDecl[parameter_, type_] :=
    CreateConstExternDecl[ToValidCSymbolString[parameter], type];

CreateConstDef[parameter_String, type_, value_] :=
    "const " <> CreateCType[type] <> " " <>
    parameter <> " = " <>
    RValueToCFormString[value] <> ";\n";

CreateConstDef[parameter_, type_, value_] :=
    CreateConstDef[ToValidCSymbolString[parameter], type, value];

MakeUnique[name_String] :=
    Module[{appendix = ""},
           While[NameQ[Evaluate[name <> appendix]] &&
                 (MemberQ[Attributes[Evaluate[name <> appendix]], Protected] ||
                  Context[Evaluate[name <> appendix]] == "SARAH`"),
                 appendix = appendix <> "x";
             ];
           Clear[Evaluate[name <> appendix]];
           Symbol[Evaluate[name <> appendix]]
          ];

MakeUniqueStr[name_String] :=
    ToString[MakeUnique[name]];

(* checks if sym contains a greek symbol *)
GreekQ[sym_] :=
    (Plus @@ (StringCount[ToString[sym], #]& /@
              {"\[Alpha]", "\[Beta]", "\[Gamma]", "\[Delta]", "\[Epsilon]",
               "\[CurlyEpsilon]", "\[Zeta]", "\[Eta]", "\[Theta]",
               "\[CurlyTheta]", "\[Iota]", "\[Kappa]", "\[CurlyKappa]",
               "\[Lambda]", "\[Mu]", "\[Nu]", "\[Xi]", "\[Omicron]",
               "\[Pi]", "\[CurlyPi]", "\[Rho]", "\[CurlyRho]",
               "\[Sigma]", "\[FinalSigma]", "\[Tau]", "\[Upsilon]",
               "\[Phi]", "\[CurlyPhi]", "\[Chi]", "\[Psi]", "\[Omega]",
               "\[Digamma]", "\[Koppa]", "\[Stigma]", "\[Sampi]"})) > 0;

ConvertGreekLetters[text_] :=
   Symbol[StringReplace[ToString[text], {
       (* replace greek symbol by uniqe greek symbol string only if
          the symbol appears alone *)
       StartOfString ~~ "\[Alpha]" ~~ EndOfString        -> MakeUniqueStr["Alpha"],
       StartOfString ~~ "\[Beta]" ~~ EndOfString         -> MakeUniqueStr["Beta"],
       StartOfString ~~ "\[Gamma]" ~~ EndOfString        -> MakeUniqueStr["Gamma"],
       StartOfString ~~ "\[Delta]" ~~ EndOfString        -> MakeUniqueStr["Delta"],
       StartOfString ~~ "\[Epsilon]" ~~ EndOfString      -> MakeUniqueStr["Epsilon"],
       StartOfString ~~ "\[CurlyEpsilon]" ~~ EndOfString -> MakeUniqueStr["CurlyEpsilon"],
       StartOfString ~~ "\[Zeta]" ~~ EndOfString         -> MakeUniqueStr["Zeta"],
       StartOfString ~~ "\[Eta]" ~~ EndOfString          -> MakeUniqueStr["Eta"],
       StartOfString ~~ "\[Theta]" ~~ EndOfString        -> MakeUniqueStr["Theta"],
       StartOfString ~~ "\[CurlyTheta]" ~~ EndOfString   -> MakeUniqueStr["CurlyTheta"],
       StartOfString ~~ "\[Iota]" ~~ EndOfString         -> MakeUniqueStr["Iota"],
       StartOfString ~~ "\[Kappa]" ~~ EndOfString        -> MakeUniqueStr["Kappa"],
       StartOfString ~~ "\[CurlyKappa]" ~~ EndOfString   -> MakeUniqueStr["CurlyKappa"],
       StartOfString ~~ "\[Lambda]" ~~ EndOfString       -> MakeUniqueStr["Lambda"],
       StartOfString ~~ "\[Mu]" ~~ EndOfString           -> MakeUniqueStr["Mu"],
       StartOfString ~~ "\[Nu]" ~~ EndOfString           -> MakeUniqueStr["Nu"],
       StartOfString ~~ "\[Xi]" ~~ EndOfString           -> MakeUniqueStr["Xi"],
       StartOfString ~~ "\[Omicron]" ~~ EndOfString      -> MakeUniqueStr["Omicron"],
       StartOfString ~~ "\[Pi]" ~~ EndOfString           -> MakeUniqueStr["Pi"],
       StartOfString ~~ "\[CurlyPi]" ~~ EndOfString      -> MakeUniqueStr["CurlyPi"],
       StartOfString ~~ "\[Rho]" ~~ EndOfString          -> MakeUniqueStr["Rho"],
       StartOfString ~~ "\[CurlyRho]" ~~ EndOfString     -> MakeUniqueStr["CurlyRho"],
       StartOfString ~~ "\[Sigma]" ~~ EndOfString        -> MakeUniqueStr["Sigma"],
       StartOfString ~~ "\[FinalSigma]" ~~ EndOfString   -> MakeUniqueStr["FinalSigma"],
       StartOfString ~~ "\[Tau]" ~~ EndOfString          -> MakeUniqueStr["Tau"],
       StartOfString ~~ "\[Upsilon]" ~~ EndOfString      -> MakeUniqueStr["Upsilon"],
       StartOfString ~~ "\[Phi]" ~~ EndOfString          -> MakeUniqueStr["Phi"],
       StartOfString ~~ "\[CurlyPhi]" ~~ EndOfString     -> MakeUniqueStr["CurlyPhi"],
       StartOfString ~~ "\[Chi]" ~~ EndOfString          -> MakeUniqueStr["Chi"],
       StartOfString ~~ "\[Psi]" ~~ EndOfString          -> MakeUniqueStr["Psi"],
       StartOfString ~~ "\[Omega]" ~~ EndOfString        -> MakeUniqueStr["Omega"],
       StartOfString ~~ "\[Digamma]" ~~ EndOfString      -> MakeUniqueStr["Digamma"],
       StartOfString ~~ "\[Koppa]" ~~ EndOfString        -> MakeUniqueStr["Koppa"],
       StartOfString ~~ "\[Stigma]" ~~ EndOfString       -> MakeUniqueStr["Stigma"],
       StartOfString ~~ "\[Sampi]" ~~ EndOfString        -> MakeUniqueStr["Sampi"],
       (* otherwise, i.e. if the symbol appears in combination with others,
          we can replace it by it's proper name *)
       "\[Alpha]"        -> "Alpha",
       "\[Beta]"         -> "Beta",
       "\[Gamma]"        -> "Gamma",
       "\[Delta]"        -> "Delta",
       "\[Epsilon]"      -> "Epsilon",
       "\[CurlyEpsilon]" -> "CurlyEpsilon",
       "\[Zeta]"         -> "Zeta",
       "\[Eta]"          -> "Eta",
       "\[Theta]"        -> "Theta",
       "\[CurlyTheta]"   -> "CurlyTheta",
       "\[Iota]"         -> "Iota",
       "\[Kappa]"        -> "Kappa",
       "\[CurlyKappa]"   -> "CurlyKappa",
       "\[Lambda]"       -> "Lambda",
       "\[Mu]"           -> "Mu",
       "\[Nu]"           -> "Nu",
       "\[Xi]"           -> "Xi",
       "\[Omicron]"      -> "Omicron",
       "\[Pi]"           -> "Pi",
       "\[CurlyPi]"      -> "CurlyPi",
       "\[Rho]"          -> "Rho",
       "\[CurlyRho]"     -> "CurlyRho",
       "\[Sigma]"        -> "Sigma",
       "\[FinalSigma]"   -> "FinalSigma",
       "\[Tau]"          -> "Tau",
       "\[Upsilon]"      -> "Upsilon",
       "\[Phi]"          -> "Phi",
       "\[CurlyPhi]"     -> "CurlyPhi",
       "\[Chi]"          -> "Chi",
       "\[Psi]"          -> "Psi",
       "\[Omega]"        -> "Omega",
       "\[Digamma]"      -> "Digamma",
       "\[Koppa]"        -> "Koppa",
       "\[Stigma]"       -> "Stigma",
       "\[Sampi]"        -> "Sampi"
    }]];

ToValidCSymbol[symbol_Symbol] := ConvertGreekLetters[symbol];

ToValidCSymbol[symbol_Integer] := symbol;

ToValidCSymbol[symbol_Real] := symbol;

ToValidCSymbol[symbol_ /; Length[symbol] > 0] :=
    Module[{result = "", i},
           For[i = 0, i <= Length[symbol], i++,
               result = result <> ToString[ToValidCSymbol[symbol[[i]]]];
              ];
           Return[Symbol[result]];
          ];

(* creates a valid C parameter name string by converting the symbol to
   a valid C variable name and removing matrix indices *)
ToValidCSymbolString[symbol_String] := symbol;

ToValidCSymbolString[symbol_] :=
    ToString[ToValidCSymbol[symbol]];

Unprotect[Complex];

Format[Complex[r_,i_],CForm] :=
    Format[CreateCType[CConversion`ScalarType[complexScalarCType]] <>
           "(" <> ToString[CForm[r]] <> "," <> ToString[CForm[i]] <> ")",
           OutputForm];

Protect[Complex];

Unprotect[Power];
Format[Power[E,z_],CForm] :=
    Format["Exp(" <> ToString[CForm[z]] <> ")", OutputForm];
Protect[Power];

Unprotect[If];
Format[If[c_,a_,b_],CForm] :=
    Format["IF(" <> ToString[CForm[c]] <> ", " <>
           ToString[CForm[Evaluate[a]]] <> ", " <>
           ToString[CForm[Evaluate[b]]] <> ")", OutputForm];
Protect[If];

Unprotect[Which];
Format[Which[cond_,args__],CForm] :=
    Format["WHICH(" <>
           Utils`StringJoinWithSeparator[CForm[Evaluate[#]]& /@ {cond,args}, ", "] <>
           ")", OutputForm];
Protect[Which];

Format[CConversion`ZEROARRAY[a_,b_],CForm] :=
    Format["ZEROARRAY(" <> ToString[CForm[a]] <> "," <>
           ToString[CForm[b]] <> ")", OutputForm];

Format[CConversion`ZEROVECTOR[a_,b_],CForm] :=
    Format["ZEROVECTOR(" <> ToString[CForm[a]] <> "," <>
           ToString[CForm[b]] <> ")", OutputForm];

Format[CConversion`ZEROMATRIX[a_,b_],CForm] :=
    Format["ZEROMATRIX(" <> ToString[CForm[a]] <> "," <>
           ToString[CForm[b]] <> ")", OutputForm];

Format[CConversion`ZEROARRAYCOMPLEX[a_,b_],CForm] :=
    Format["ZEROARRAYCOMPLEX(" <> ToString[CForm[a]] <> "," <>
           ToString[CForm[b]] <> ")", OutputForm];

Format[CConversion`ZEROVECTORCOMPLEX[a_,b_],CForm] :=
    Format["ZEROVECTORCOMPLEX(" <> ToString[CForm[a]] <> "," <>
           ToString[CForm[b]] <> ")", OutputForm];

Format[CConversion`ZEROMATRIXCOMPLEX[a_,b_],CForm] :=
    Format["ZEROMATRIXCOMPLEX(" <> ToString[CForm[a]] <> "," <>
           ToString[CForm[b]] <> ")", OutputForm];

Format[CConversion`FSKroneckerDelta[a_,b_],CForm] :=
    Format["KroneckerDelta(" <> ToString[CForm[a]] <> "," <>
           ToString[CForm[b]] <> ")", OutputForm];

Format[SARAH`L[x_],CForm] :=
    Format[ToValidCSymbol[SARAH`L[x /. FlexibleSUSY`GreekSymbol -> Identity]], OutputForm];

Format[SARAH`B[x_],CForm] :=
    Format[ToValidCSymbol[SARAH`B[x /. FlexibleSUSY`GreekSymbol -> Identity]], OutputForm];

Format[SARAH`T[x_],CForm] :=
    Format[ToValidCSymbol[SARAH`T[x /. FlexibleSUSY`GreekSymbol -> Identity]], OutputForm];

Format[SARAH`Q[x_],CForm] :=
    Format[ToValidCSymbol[SARAH`Q[x /. FlexibleSUSY`GreekSymbol -> Identity]], OutputForm];

Format[FlexibleSUSY`GreekSymbol[x_],CForm] :=
    Format[ToValidCSymbol[x], OutputForm];

Format[SARAH`Conj[x_],CForm] :=
    If[SARAH`getDimParameters[x /. FlexibleSUSY`GreekSymbol -> Identity] === {} ||
       SARAH`getDimParameters[x /. FlexibleSUSY`GreekSymbol -> Identity] === {0},
       Format["Conj(" <> ToString[CForm[x]] <> ")", OutputForm],
       Format[ToString[CForm[x]] <> ".conjugate()", OutputForm]
      ];

Format[SARAH`Adj[x_Symbol],CForm]       := Format[ToString[CForm[x]] <> ".adjoint()"  , OutputForm];

Format[SARAH`Adj[x_],CForm]             :=
    Format["(" <> ToString[CForm[x]] <> ").adjoint()"  , OutputForm];

Format[SARAH`Tp[x_Symbol],CForm]        := Format[ToString[CForm[x]] <> ".transpose()", OutputForm];

Format[SARAH`Tp[x_],CForm]              :=
    Format["(" <> ToString[CForm[x]] <> ").transpose()", OutputForm];

Format[SARAH`Tp[x__],CForm]             :=
    Format[SARAH`Tp[Times[x]],CForm];

Format[SARAH`trace[HoldPattern[x_Symbol]],CForm] :=
    Format[ToString[CForm[HoldForm[x]]] <> ".trace()", OutputForm];

Format[SARAH`trace[HoldPattern[x_]],CForm] :=
    Format["(" <> ToString[CForm[HoldForm[x]]] <> ").trace()", OutputForm];

Format[SARAH`ScalarProd[HoldPattern[x_Symbol], HoldPattern[y_]],CForm] :=
    Format[ToString[CForm[HoldForm[x]]] <> ".dot(" <> ToString[CForm[HoldForm[y]]] <> ")", OutputForm];

Format[SARAH`ScalarProd[HoldPattern[x_], HoldPattern[y_]],CForm] :=
    Format["(" <> ToString[CForm[HoldForm[x]]] <> ").dot(" <> ToString[CForm[HoldForm[y]]] <> ")", OutputForm];

Format[CConversion`TensorProd[HoldPattern[x_Symbol],HoldPattern[y_Symbol]],CForm] :=
    Format[ToString[CForm[HoldForm[x]]] <> "*" <>
           ToString[CForm[HoldForm[y]]] <> ".transpose()", OutputForm];

Format[CConversion`TensorProd[HoldPattern[x_Symbol],HoldPattern[y_]],CForm] :=
    Format[ToString[CForm[HoldForm[x]]] <> "*(" <>
           ToString[CForm[HoldForm[y]]] <> ").transpose()", OutputForm];

Format[CConversion`TensorProd[HoldPattern[x_],HoldPattern[y_Symbol]],CForm] :=
    Format["(" <> ToString[CForm[HoldForm[x]]] <> ")*" <>
           ToString[CForm[HoldForm[y]]] <> ".transpose()", OutputForm];

Format[CConversion`TensorProd[HoldPattern[x_],HoldPattern[y_]],CForm] :=
    Format["(" <> ToString[CForm[HoldForm[x]]] <> ")*(" <>
           ToString[CForm[HoldForm[y]]] <> ").transpose()", OutputForm];

(* Finds all Greek symbols in an expression.
   Note: All arguments of Which and If are evaluated.
 *)
FindGreekSymbols[expr_] :=
    Block[{Which, If},
          DeleteDuplicates @ Select[
              Cases[expr, x_Symbol | x_Symbol[__] :> x, {0,Infinity}, Heads->True], GreekQ]
         ];

(* Converts an expression to CForm and expands SARAH symbols
 *
 *   MatMul[A]      ->   A
 *   MatMul[A,B]    ->   A * B
 *   MatMul[A,B,C]  ->   A * B * C
 *   MatMul[A,B,A]  ->   A * B * A
 *   trace[A,B]     ->   trace[A * B]
 *   trace[A,B,A]   ->   trace[A * B * A]
 *
 * etc.
 *)
RValueToCFormString[expr_String] := expr;

RValueToCFormString[expr_] :=
    Module[{times, result, greekSymbolsRules, conjSimplification = {}},
           greekSymbolsRules = Rule[#, FlexibleSUSY`GreekSymbol[#]]& /@ FindGreekSymbols[expr];
           (* create complicated conj simplification rules only when needed *)
           If[!FreeQ[expr, Susyno`LieGroups`conj] || !FreeQ[expr, SARAH`Conj],
              conjSimplification = {
                  Times[x___, SARAH`Conj[a_], y___, a_, z___] :> AbsSqr[a] x y z,
                  Times[x___, a_, y___, SARAH`Conj[a_], z___] :> AbsSqr[a] x y z
              };
             ];
           result = Block[{Which, If}, expr /. greekSymbolsRules] /.
                    SARAH`sum -> FlexibleSUSY`SUM /.
                    SARAH`Mass -> FlexibleSUSY`M //. {
                    SARAH`A0[SARAH`Mass2[a_]]              :> SARAH`A0[FlexibleSUSY`M[a]],
                    SARAH`B0[a___, SARAH`Mass2[b_], c___]  :> SARAH`B0[a,FlexibleSUSY`M[b],c],
                    SARAH`B1[a___, SARAH`Mass2[b_], c___]  :> SARAH`B1[a,FlexibleSUSY`M[b],c],
                    SARAH`B00[a___, SARAH`Mass2[b_], c___] :> SARAH`B00[a,FlexibleSUSY`M[b],c],
                    SARAH`B22[a___, SARAH`Mass2[b_], c___] :> SARAH`B22[a,FlexibleSUSY`M[b],c],
                    SARAH`F0[a___, SARAH`Mass2[b_], c___]  :> SARAH`F0[a,FlexibleSUSY`M[b],c],
                    SARAH`G0[a___, SARAH`Mass2[b_], c___]  :> SARAH`G0[a,FlexibleSUSY`M[b],c],
                    SARAH`H0[a___, SARAH`Mass2[b_], c___]  :> SARAH`H0[a,FlexibleSUSY`M[b],c] } /. {
                    SARAH`A0[p_^2]                   :> SARAH`A0[p],
                    SARAH`B0[p_^2, a__]              :> SARAH`B0[p, a],
                    SARAH`B1[p_^2, a__]              :> SARAH`B1[p, a],
                    SARAH`B00[p_^2, a__]             :> SARAH`B00[p, a],
                    SARAH`B22[p_^2, a__]             :> SARAH`B22[p, a],
                    SARAH`F0[p_^2, a__]              :> SARAH`F0[p, a],
                    SARAH`G0[p_^2, a__]              :> SARAH`G0[p, a],
                    SARAH`H0[p_^2, a__]              :> SARAH`H0[p, a] } /.
                    SARAH`A0[0]              -> 0 /.
                    SARAH`Mass2[a_?NumberQ]  :> Sqr[a] /.
                    SARAH`Mass2[a_]          :> Sqr[FlexibleSUSY`M[a]] /.
                    FlexibleSUSY`M[a_?NumberQ]   :> a /.
                    FlexibleSUSY`M[SARAH`bar[a_]] :> FlexibleSUSY`M[a] /.
                    FlexibleSUSY`M[a_[idx_]]     :> ToValidCSymbol[FlexibleSUSY`M[a]][idx] /.
                    FlexibleSUSY`M[a_]           :> ToValidCSymbol[FlexibleSUSY`M[a]] /.
                    FlexibleSUSY`BETA[l_,p_]     :> FlexibleSUSY`BETA1[l,p] /.
                    Susyno`LieGroups`conj    -> SARAH`Conj //.
                    conjSimplification /.
                    SARAH`Delta[a_,a_]       -> 1 /.
                    Power[a_?NumericQ,n_?NumericQ] :> N[Power[a,n]] /.
                    Sqrt[a_?NumericQ]        :> N[Sqrt[a]] /.
                    Rational[a_?NumericQ, b_?NumericQ] :> N[Rational[a,b]] /.
                    Power[a_,0.5]            :> Sqrt[a] /.
                    Power[a_,-0.5]           :> 1/Sqrt[a] /.
                    Power[a_,1/3]            :> Cbrt[a] /.
                    Power[a_,-1/3]           :> 1/Cbrt[a] /.
                    Power[a_,2]              :> Sqr[a] /.
                    Power[a_,-2]             :> 1/Sqr[a] /.
                    Power[a_,3]              :> Cube[a] /.
                    Power[a_,-3]             :> 1/Cube[a] /.
                    Power[a_,4]              :> Quad[a] /.
                    Power[a_,-4]             :> 1/Quad[a] /.
                    Power[a_,5]              :> Power5[a] /.
                    Power[a_,-5]             :> 1/Power5[a] /.
                    Power[a_,6]              :> Power6[a] /.
                    Power[a_,-6]             :> 1/Power6[a] /.
                    Power[a_,7]              :> Power7[a] /.
                    Power[a_,-7]             :> 1/Power7[a] /.
                    Power[a_,8]              :> Power8[a] /.
                    Power[a_,-8]             :> 1/Power8[a] /.
                    Sqrt[x_]/Sqrt[y_]        :> Sqrt[x/y];
           result = Apply[Function[code, Hold[CForm[code]], HoldAll],
                          Hold[#] &[result /. { SARAH`MatMul[a__] :> times @@ SARAH`MatMul[a],
                                                SARAH`trace[a__]  :> SARAH`trace[times[a]],
                                                Piecewise[{{val_, cond_}}, default_] :> If[cond, val, default] }]
                          /. times -> Times
                         ];
           ToString[HoldForm @@ result]
          ];

(* returns the head of a symbol
 * GetHead[s]        ->  s
 * GetHead[s[a]]     ->  s
 * GetHead[s[a][b]]  ->  s
 *)
GetHead[sym_] :=
    Module[{result},
           result = sym;
           If[IntegerQ[result] || RealQ[result], Return[result]];
           While[Head[result] =!= Symbol, result = Head[result]];
           Return[result];
          ];

(* this variable is increased during each call of
   CreateUniqueCVariable[] *)
sumVariableCounter = 0;

CreateUniqueCVariable[] :=
    Module[{variable},
           variable = "tmp_" <> ToString[sumVariableCounter];
           sumVariableCounter++;
           Return[variable];
          ];

ProtectTensorProducts[expr_, idx1_, idx2_] :=
    Expand[expr] //.
    { a_[idx1] b_[idx2] :> CConversion`TensorProd[a, b][idx1,idx2],
      Susyno`LieGroups`conj[a_][idx1] b_[idx2] :>
      CConversion`TensorProd[Susyno`LieGroups`conj[a], b][idx1,idx2],
      a_[idx1] Susyno`LieGroups`conj[b_][idx2] :>
      CConversion`TensorProd[a, Susyno`LieGroups`conj[b]][idx1,idx2]
    } //.
    { CConversion`TensorProd[a_, b_][i_,k_] + CConversion`TensorProd[a_, c_][i_,k_] :>
      CConversion`TensorProd[a, b+c][i,k],
      CConversion`TensorProd[a_, b_][i_,k_] + CConversion`TensorProd[c_, b_][i_,k_] :>
      CConversion`TensorProd[a+c, b][i,k]
    };

ProtectTensorProducts[expr_, sym_] := expr;

ProtectTensorProducts[expr_, sym_[_]] := expr;

ProtectTensorProducts[expr_, sym_[idx1_, idx2_]] :=
    ProtectTensorProducts[expr, idx1, idx2];

HaveSameDimension[_] := True;
HaveSameDimension[{}] := True;
HaveSameDimension[types__] := HaveSameDimension[{types}];
HaveSameDimension[{ScalarType[_], ScalarType[_]}] := True;
HaveSameDimension[{ArrayType[_,n_], ArrayType[_,m_]}] := n === m;
HaveSameDimension[{VectorType[_,n_], VectorType[_,m_]}] := n === m;
HaveSameDimension[{VectorType[_,n_], ArrayType[_,m_]}] := n === m;
HaveSameDimension[{MatrixType[_,n_,k_], MatrixType[_,m_,l_]}] := n === m && k === l;
HaveSameDimension[{MatrixType[_,dims1__], MatrixType[_,dims2__]}] :=
    And @@ ((#[[1]] == #[[2]])& /@ Utils`Zip[{dims1},{dims2}]);
HaveSameDimension[{_,_}] := False;
HaveSameDimension[types_List] :=
    And @@ (HaveSameDimension /@ Subsets[types, {2}]);


CountNumberOfEntries[CConversion`realScalarCType]    := 1;
CountNumberOfEntries[CConversion`integerScalarCType] := 1;
CountNumberOfEntries[CConversion`complexScalarCType] := 2;

CountNumberOfEntries[CConversion`ScalarType[type_]]     := CountNumberOfEntries[type];
CountNumberOfEntries[CConversion`ArrayType[type_, n_]]  := n CountNumberOfEntries[type];
CountNumberOfEntries[CConversion`VectorType[type_, n_]] := n CountNumberOfEntries[type];
CountNumberOfEntries[CConversion`MatrixType[type_, m_, n_]] := m n CountNumberOfEntries[type];
CountNumberOfEntries[CConversion`TensorType[type_, dims__]] := Times[dims] CountNumberOfEntries[type];

(* rewrite sums (Author: Jae-hyeon Park *)
RefactorSums[expr_] := SumOverToSum @ RecordSumCosts @ Expand @
		       NestedSumToSumOver @ RecordSumDepths[expr /. Eval -> Identity, {}];

RecordSumDepths[x_?AtomQ, depths_] := x;

RecordSumDepths[x_, depths_] := RecordSumDepths[#, depths]& /@ x;

RecordSumDepths[SARAH`sum[idx_, a_, b_, x_], {p___, m:{a_|b_,depth_}, q___}] :=
    NestedSum[depth - 1, idx, a, b,
	RecordSumDepths[x, {p, m, q, {idx, depth - 1}}]];

RecordSumDepths[SARAH`sum[idx_, a_, b_, x_], {p___}] :=
    NestedSum[0, idx, a, b, RecordSumDepths[x, {p, {idx, 0}}]];

NestedSumToSumOver[expr_] := expr //.
    NestedSum[depth_, idx_, a_, b_, x_] :> SumOver[depth, idx, a, b] x;

RecordSumCosts[expr_] := expr //.
    SumOver[depth_Integer, idx_, a_, b_] x_ :>
    SumOver[{depth, IndexCost[idx, x]}, idx, a, b] x;

SumOverToSum[prod : SumOver[_,_,_,_] _] := Module[{
	lst = List @@ prod,
	sumOverToConvert,
	idx, a, b, summand
    },
    sumOverToConvert = First @ Sort[Cases[lst, SumOver[_,_,_,_]]];
    {idx, a, b} = Drop[List @@ sumOverToConvert, 1];
    summand = Select[DeleteCases[lst, sumOverToConvert],
		     !FreeQ[#, idx]&];
    SumOverToSum[SARAH`sum[idx, a, b, Eval[SumOverToSum[Times @@ summand]]]
		 Times @@ Complement[lst, {sumOverToConvert}, summand]]
];

SumOverToSum[x_Plus] := SumOverToSum /@ x;

SumOverToSum[x_] := x;

IndexCost[idx_, _?AtomQ] := 0;

IndexCost[idx_, x_] /; NumericQ[FunctionCost[x]] && !FreeQ[x, idx] :=
    FunctionCost[x];

IndexCost[idx_, x_] := Plus @@ (IndexCost[idx, #]& /@ List @@ x);

(* cost functions *)
FunctionCost[SARAH`A0[_]]  := 1;
FunctionCost[SARAH`B0[__]] := 2;
FunctionCost[SARAH`B1[__]] := 2;
FunctionCost[SARAH`B00[__]] := 2;
FunctionCost[SARAH`B22[__]] := 2;
FunctionCost[SARAH`F0[__]] := 2;
FunctionCost[SARAH`G0[__]] := 2;
FunctionCost[SARAH`H0[__]] := 2;

End[];

EndPackage[];
