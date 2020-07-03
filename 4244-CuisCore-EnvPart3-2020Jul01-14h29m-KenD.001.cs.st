'From Cuis 5.0 [latest update: #4242] on 1 July 2020 at 3:44:32 pm'!

!UndefinedObject methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 05:29:21'!
environment

	^Smalltalk! !

!UndefinedObject methodsFor: '*system-environments' stamp: 'KenD 6/30/2020 13:42:54'!
environmentsExportMe

	^false! !

!MethodReference methodsFor: '*system-environments' stamp: 'KenD 6/28/2020 15:40:09'!
environment

	^categoryName 
		ifNil: [ Smalltalk ]
		ifNotNil:  [ Smalltalk environmentFromSystemCategory: categoryName ]! !

!CodeFileBrowser methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 02:14:24'!
baseCodeSource
	^ baseCodeSource ifNil: [ self environment ]! !

!CodeFileBrowser methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 02:14:19'!
caseCodeSource
	^ caseCodeSource ifNil: [ self environment ]! !

!ChangeSorter methodsFor: '*system-environments' stamp: 'KenD 6/17/2020 14:45:40'!
selectedClassOrMetaClass
	"Careful, the class may have been removed!!"
	"Nota Bene: overwrites base system method"

	| cName cEnv |
	currentClassName ifNil: [^ nil].
	cEnv := myChangeSet codePackage ifNil: [ Smalltalk ] ifNotNil: [ :pkg | pkg environment ].
	(currentClassName endsWith: ' class')
		ifTrue: [
			cName _ (currentClassName copyFrom: 1 to: currentClassName size-6) asSymbol.
			^ (cEnv at: cName ifAbsent: [^nil]) class]
		ifFalse: [
			cName _ currentClassName asSymbol.
			^ cEnv at: cName ifAbsent: nil]! !

!ChangeList methodsFor: '*system-environments' stamp: 'KenD 7/1/2020 15:41:15'!
scanCategory: category class: class meta: meta stamp: stamp prior: aPriorMethod overrides: anOverridenMethod
	"Nota Bene: replaces base system method"
	| itemPosition method environment |
	environment := Smalltalk environmentFromSystemCategory: category.
	[
		itemPosition _ file position.
		method _ file nextChunk.
		method notEmpty ] whileTrue: [ "done when double terminators"
			self
				addItem: (ChangeRecord new 
					file: file 
					position: itemPosition 
					type: #method
					class: class 
					category: category 
					meta: meta 
					stamp: stamp
					prior: aPriorMethod
					overrides: anOverridenMethod)
				text: 'method: ' , class , (meta ifTrue: [' class '] ifFalse: [' '])
					, (((environment at: class ifAbsent: [Object ]) class parserClass selectorFrom: method) ifNil: [''])
					, (stamp isEmpty ifTrue: [''] ifFalse: ['; ' , stamp])]! !


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

