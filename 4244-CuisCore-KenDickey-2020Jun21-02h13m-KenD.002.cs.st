'From Cuis 5.0 [latest update: #4243] on 21 June 2020 at 2:48:51 am'!

!UndefinedObject methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 02:47:55'!
environment

	^Smalltalk! !


!CodeFileBrowser methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 02:14:24'!
baseCodeSource
	^ baseCodeSource ifNil: [ self environment ]! !

!CodeFileBrowser methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 02:14:19'!
caseCodeSource
	^ caseCodeSource ifNil: [ self environment ]! !


!CodeFileBrowser reorganize!
('accessing' acceptedStringOrText baseCodeSource: caseCodeSource: contents:notifying: contentsSymbol)
('class list' classList renameClass selectedClass)
('diffs' methodDiffFor:selector: modifiedClassDefinition)
('edit pane' selectedBytecodes selectedMessage)
('fileIn/fileOut' fileIn fileInClass fileInMessage fileInMessageCategories fileOut fileOutClass fileOutMessage fileOutMessageCategories)
('infoView' annotation extraInfo infoViewContents updateInfoView)
('menus' contentsSymbolQuints)
('message list' messageList)
('metaclass' selectedClassOrMetaClass setClassOrganizer)
('other' changeMessageCategories: didCodeChangeElsewhere labelString)
('removing' removeClass removeMessage removeMessageCategory removeUnmodifiedCategories removeUnmodifiedClasses removeUnmodifiedMethods)
('shout styling' shouldStyle:with:)
('private' pvtBaseClassOrMetaclass pvtBaseSelectedMessageSourceCodeFor: pvtCaseSelectedMessageSourceCodeFor:)
!


!UndefinedObject reorganize!
('evaluating' valueWithPossibleArgs: valueWithPossibleArgument: valueWithPossibleArgument:and:)
('copying' shallowCopy)
('printing' printOn: storeOn:)
('testing' ifNil: ifNil:ifNotNil: ifNotNil: ifNotNil:ifNil: isEmptyOrNil isLiteral isNil notNil)
('dependents access' addDependent: suspend)
('class hierarchy' addSubclass: allSuperclassesUpTo: literalScannedAs:notifying: removeSubclass: subclass:instanceVariableNames:classVariableNames:poolDictionaries:category: subclasses subclassesDo: subclassesDoGently: superclassNotValidErrorDescriptionFor: typeOfClass)
('bottom context' canHandleSignal: handleSignal:)
('accessing instances and variables' whichClassDefinesInstanceVariable:ifNone:)
!

