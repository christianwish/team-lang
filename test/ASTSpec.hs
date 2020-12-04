{-# LANGUAGE OverloadedStrings #-}

module ASTSpec where

    import Test.Hspec
    import Text.RawString.QQ
    import qualified Data.ByteString.Lazy.Char8 as L
    import Tokenizer
    import Syntax

    spec :: Spec
    spec = do
        describe "Syntax" $ do
            it "Parameter: \"(a, b)\"" $ do
                let actual = isParamterList $ generateTokens "()"
                    expected = (
                        [AST_NODE {
                              _astNodeType = AstParameterList
                            , _astTokens = []
                            , _astChildren = []
                            }
                        ],
                        []
                        )
                actual `shouldBe` expected

            it "List: \"[1 [2 [3 true]]]\"" $ do
                let actual = isList $ generateTokens "[1 [2 [3 true]]]"
                    expected = (
                        [
                            AST_NODE {_astNodeType = AstList, _astTokens = [], _astChildren = [
                                AST_NODE {_astNodeType = AstPrimitiv, _astTokens = [Token {_TType = T_Number, _TValue = "1", _TIndex = 1}], _astChildren = []},
                                AST_NODE {_astNodeType = AstList, _astTokens = [], _astChildren = [
                                    AST_NODE {_astNodeType = AstPrimitiv, _astTokens = [Token {_TType = T_Number, _TValue = "2", _TIndex = 4}], _astChildren = []},
                                    AST_NODE {_astNodeType = AstList, _astTokens = [], _astChildren = [
                                        AST_NODE {_astNodeType = AstPrimitiv, _astTokens = [Token {_TType = T_Number, _TValue = "3", _TIndex = 7}], _astChildren = []},
                                        AST_NODE {_astNodeType = AstPrimitiv, _astTokens = [Token {_TType = T_BooleanTrue, _TValue = "true", _TIndex = 9}], _astChildren = []}
                                    ]}
                                ]}
                            ]}
                        ],
                        []
                        )
                actual `shouldBe` expected

            it "Function: \"{fn () 3}\"" $ do
                let actual = isFunction $ generateTokens "{fn () 3}"
                    expected =  ([
                                    AST_NODE {_astNodeType = AstFunction, _astTokens = [], _astChildren = [
                                        AST_NODE {_astNodeType = AstSymbol, _astTokens = [Token {_TType = T_Symbol, _TValue = "fn", _TIndex = 1}], _astChildren = []},
                                        AST_NODE {_astNodeType = AstParameterList, _astTokens = [], _astChildren = []},
                                        AST_NODE {_astNodeType = AstFunctionBody, _astTokens = [], _astChildren = [
                                            AST_NODE {_astNodeType = AstPrimitiv, _astTokens = [Token {_TType = T_Number, _TValue = "3", _TIndex = 6}], _astChildren = []}
                                        ]}
                                    ]}
                                ],
                                [])

                actual `shouldBe` expected

            it "Function: \"{fn () a}\"" $ do
                let actual = isFunction $ generateTokens "{fn () a}"
                    expected = ([
                                    AST_NODE {_astNodeType = AstFunction, _astTokens = [], _astChildren = [
                                        AST_NODE {_astNodeType = AstSymbol, _astTokens = [Token {_TType = T_Symbol, _TValue = "fn", _TIndex = 1}], _astChildren = []},
                                        AST_NODE {_astNodeType = AstParameterList, _astTokens = [], _astChildren = []},
                                        AST_NODE {_astNodeType = AstFunctionBody, _astTokens = [], _astChildren = [
                                            AST_NODE {_astNodeType = AstSymbol, _astTokens = [Token {_TType = T_Symbol, _TValue = "a", _TIndex = 6}], _astChildren = []}
                                        ]}
                                    ]}
                                ],
                                [])
                actual `shouldBe` expected

            it "Function: \"{fn (a) (+ a 1)}\"" $ do
                let actual = isFunction $ generateTokens "{fn (a) (+ a 1)}"
                    expected = ([
                                AST_NODE {_astNodeType = AstFunction, _astTokens = [], _astChildren = [
                                    AST_NODE {_astNodeType = AstSymbol, _astTokens = [Token {_TType = T_Symbol, _TValue = "fn", _TIndex = 1}], _astChildren = []},
                                    AST_NODE {_astNodeType = AstParameterList, _astTokens = [], _astChildren = [
                                        AST_NODE {_astNodeType = AstParameter, _astTokens = [Token {_TType = T_Symbol, _TValue = "a", _TIndex = 4}], _astChildren = []}]},
                                    AST_NODE {_astNodeType = AstFunctionBody, _astTokens = [], _astChildren = [
                                        AST_NODE {_astNodeType = AstFunctionCall, _astTokens = [], _astChildren = [
                                            AST_NODE {_astNodeType = AstSymbol, _astTokens = [Token {_TType = T_Symbol, _TValue = "+", _TIndex = 8}], _astChildren = []},
                                            AST_NODE {_astNodeType = AstSymbol, _astTokens = [Token {_TType = T_Symbol, _TValue = "a", _TIndex = 10}], _astChildren = []},
                                            AST_NODE {_astNodeType = AstPrimitiv, _astTokens = [Token {_TType = T_Number, _TValue = "1", _TIndex = 12}], _astChildren = []}
                                        ]}
                                    ]}
                                ]}
                            ],[])
                actual `shouldBe` expected

            it "Lambda: \"{(a) (a)}\"" $ do
                let actual = isLambda $ generateTokens "{(a) (a)}"
                    expected = ([
                                AST_NODE {_astNodeType = AstLambda, _astTokens = [], _astChildren = [
                                    AST_NODE {_astNodeType = AstParameterList, _astTokens = [], _astChildren = [
                                        AST_NODE {_astNodeType = AstParameter, _astTokens = [Token {_TType = T_Symbol, _TValue = "a", _TIndex = 2}], _astChildren = []}]},
                                    AST_NODE {_astNodeType = AstFunctionBody, _astTokens = [], _astChildren = [
                                        AST_NODE {_astNodeType = AstFunctionCall, _astTokens = [], _astChildren = [
                                            AST_NODE {_astNodeType = AstSymbol, _astTokens = [Token {_TType = T_Symbol, _TValue = "a", _TIndex = 6}], _astChildren = []}
                                        ]}
                                    ]}
                                ]}
                            ],[])
                actual `shouldBe` expected

            it "Enum: \"(enum T :a)\"" $ do
                let actual = isEnum $ generateTokens "(enum T :a)"
                    expected = ([
                                AST_NODE {_astNodeType = AstEnum, _astTokens = [], _astChildren = [
                                    AST_NODE {_astNodeType = AstTypeSymbol, _astTokens = [Token {_TType = T_Type, _TValue = "T", _TIndex = 3}], _astChildren = []},
                                    AST_NODE {_astNodeType = AstEnumMember, _astTokens = [Token {_TType = T_NamedParameter, _TValue = ":a", _TIndex = 5}], _astChildren = []}
                                ]}
                            ],[])
                actual `shouldBe` expected

            -- it "Enum: \"(enum T)\"" $ do -- TODO: AstError check
            --     let actual = isEnum $ generateTokens "(enum T)"
            --         expected = ([],[])
            --     actual `shouldBe` expected
