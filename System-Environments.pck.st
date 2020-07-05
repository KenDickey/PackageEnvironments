'From Cuis 5.0 [latest update: #4241] on 5 July 2020 at 1:16:35 pm'!
'Description Environments are associated with packaged Features, whose class namespace is disjoint from Smalltalk.

This allows importing multiple Feature/Package Classes with the same name.'!
!provides: 'System-Environments' 1 13!
!requires: 'Cuis-Base' 50 4241 nil!
SystemOrganization addCategory: #'System-Environments'!


!classDefinition: #Environment category: #'System-Environments'!
IdentityDictionary subclass: #Environment
	instanceVariableNames: 'name packageName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'System-Environments'!
!classDefinition: 'Environment class' category: #'System-Environments'!
Environment class
	instanceVariableNames: ''!


!Environment commentStamp: '<historical>' prior: 0!
Environments are associated with packaged Features, whose Class NameSpace is disjoint from Smalltalk.

This allows importing multiple Feature/Package Classes with the same name.

I am an IdentityDictionary which holds the bindings of ClassNameSymbol->Class so my classes can be found and used.

I am usually added to Smalltalk and also, as a sharedPool, to classes added by my named Feature.  

The binding in Smalltalk allows access to my Classes via  <me> @ classNameSym.

The sharedPools allow lookup without changing Class>>bindingOf:

Think of me as an extension of Feature.

!

!Environment methodsFor: 'accessing' stamp: 'KenD 6/9/2020 09:38:16'!
name

	^name! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/12/2020 14:24:54'!
package

	^ (self packageName) 
		ifNotNil: [ :pkgName | CodePackage installedPackages at: pkgName ifAbsent: []]
		ifNil: [ CodePackage installedPackages detect: [:one| one environment == self] ifNone: [] ]! !

!Environment methodsFor: 'printing' stamp: 'len 6/12/2020 08:22:40'!
printOn: aStream
	aStream nextPutAll: self name; nextPutAll: ' environment'! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/8/2020 08:19:50'!
@ classNameSymbol

	^ self at: classNameSymbol ! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/21/2020 02:23:07'!
classNamed: className 
	"className is either a class name or a class name followed by ' class'.
	Answer the class or metaclass it names.
	Answer nil if no class by that name."
	
	self at: className asSymbol ifPresent: [ :found |
		^ found isBehavior ifTrue: [ found ]].

	(className withoutSuffix: ' class') ifNotNil: [ :baseName |
		self at: baseName asSymbol ifPresent: [ :found |
			^ found isBehavior ifTrue: [ found class ]]].

	^ nil! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/12/2020 13:37:05'!
packageName

	^packageName! !

!Environment methodsFor: 'initialization' stamp: 'KenD 6/21/2020 16:42:18'!
fromCodePackage: aCodePackage
	"Convert from an already filed in Feature/Package.
	 Answer a new Environment."
	
	| pkgReqNames otherEnironments |
	packageName := aCodePackage packageName.
	name := packageName asEnvironmentName asSymbol.
	"The basic difference is registration of Classes; remove Classes from Smalltalk"
	aCodePackage classesDo: [ :cls |
		self declare: cls name from: Smalltalk. "transfer association"
		cls addSharedPool: self. "Add me to my Classes shared pool"
	].
	"Any requirement which is an Environment should be added to my Classes shared pools"
	pkgReqNames := self requirementNamesFromCodePackage: aCodePackage.
	otherEnironments := OrderedCollection new.
	pkgReqNames do: [ :pkgName | | possibleEnvironment |
		possibleEnvironment := Smalltalk at: pkgName asEnvironmentName asSymbol
											ifAbsent: [nil].
		(possibleEnvironment is: #Environment)
			ifTrue: [ otherEnironments addLast: possibleEnvironment ]
	].
	(otherEnironments size > 0) ifTrue: [
		self classesDo: [ :aClass |
			otherEnironments do: [ :env | aClass addSharedPool: env]
		]
	].
	self classesDo: [ :aClass |
			((aClass environmentsExportMe)
				and: [(aClass name = name) not])  "Don't let Class shadow Me (see doesNotUNderstand:)"
				ifTrue: [ Smalltalk at: aClass name put: aClass ]
	].
	Smalltalk at: name put: self.
	CodeWindow allSubInstancesDo: [ :b | b updateListsAndCode ] "Keep UI up to date"
! !

!Environment methodsFor: 'initialization' stamp: 'KenD 6/9/2020 09:03:14'!
fromFeature: aString
	"Similar to Feature>>require: but (sub)Class names are not
	 registed in dictionary Smalltalk.
	 Answer a new Environment."
	self notYetImplemented ! !

!Environment methodsFor: 'initialization' stamp: 'len 6/12/2020 08:40:10'!
name: aString
	name _ aString asSymbol! !

!Environment methodsFor: 'initialization' stamp: 'KenD 6/12/2020 14:32:04'!
name: aSymbol packageName: aString
	name _  aSymbol.
	packageName _ aString! !

!Environment methodsFor: 'error handling' stamp: 'KenD 7/5/2020 11:58:16'!
doesNotUnderstand: aMessage
	"Answer a Class if Class name used as a selector"
	^ self at: aMessage selector "Name for a Class in me?"
		  ifAbsent: [ | aClass |
			"An Environment may contain a Class of the same name"
			"If not, delegate to Smalltalk. 
			As System Dictionary protocol much larger than IdentityDictionary protocol"
			aClass _ (self at: name 
					ifAbsent: [ ^self reallyDoesNotUnderstand: aMessage  ]).
			(aClass class canUnderstand: aMessage selector) "Must be a Class method with this selector"
				ifTrue: [
					Transcript addEntry: self printString, ' delegates to ', 
						aClass printString, ' ',
						aMessage selector asString, ' ',
						aMessage arguments printString.	
					aClass perform: aMessage selector withArguments: aMessage arguments
				]
				ifFalse: [ self reallyDoesNotUnderstand: aMessage  ]
		 ]
	! !

!Environment methodsFor: 'error handling' stamp: 'KenD 7/5/2020 11:56:49'!
reallyDoesNotUnderstand: aMessage
	"See if we can delegate to Smalltalk"
	(Smalltalk  class canUnderstand: aMessage selector) 
	ifTrue:  [
		Transcript addEntry: self printString, ' delegates to  Smalltalk ', 
						aMessage selector asString, ' ',
						aMessage arguments printString.
		Smalltalk perform: aMessage selector withArguments: aMessage arguments
	]
	ifFalse:  [ super doesNotUnderstand: aMessage ]! !

!Environment methodsFor: 'private' stamp: 'KenD 6/15/2020 09:11:45'!
requirementNames
	"Answer ordered requirement package names"

	| reqNames |
	reqNames := OrderedCollection new.  "We can have duplicate Class names. Keep order"
	
	self notYetImplemented.
	^reqNames! !

!Environment methodsFor: 'private' stamp: 'KenD 6/15/2020 13:56:55'!
requirementNamesFromCodePackage: aCodePackage
	"Answer ordered requirement package names.
	 CodePackage => all requirements already satisfied."

	| namesToReturn namesToProcess packageDict |
	namesToReturn := OrderedCollection new.  "We can have duplicate Class names. Keep order"
	namesToProcess := 
			 (aCodePackage featureSpec requires collect: [ :r | r name ]) asOrderedCollection.
	packageDict := CodePackage installedPackages.
	[namesToProcess size > 0] whileTrue: [ |pkgName|
		pkgName := namesToProcess removeFirst.
		((namesToReturn includes: pkgName) or: [pkgName = #'Cuis-Base'])
			ifFalse: [
				namesToReturn addLast: pkgName.
				namesToProcess addAllLast: 
						((packageDict at: pkgName) featureSpec requires collect: [ :r | r name ])
			]
	].
	^namesToReturn! !

!Environment methodsFor: 'testing' stamp: 'KenD 6/30/2020 13:56:11'!
environmentsExportMe

	^false! !

!Environment methodsFor: 'testing' stamp: 'KenD 6/9/2020 14:34:11'!
is: aSymbol
	^ aSymbol == #Environment or: [ super is: aSymbol ]! !

!Environment methodsFor: 'enumerating' stamp: 'KenD 6/15/2020 14:46:31'!
classesDo: aBlock
	"My Dictionary values are all my Classes"
	self valuesDo: aBlock! !

!Environment class methodsFor: 'instance creation' stamp: 'KenD 6/21/2020 18:18:42'!
fromCodePackage: aCodePackage
	"Convert from an already filed in Feature/Package.
	 Answer a new Environment."
	| envName |
	envName _ aCodePackage packageName asEnvironmentName.
	((Smalltalk includesKey: envName asSymbol) and: [(Smalltalk at: envName asSymbol) is: #Environment])
		ifTrue: [self inform: envName, ' already esists as an environent.  Fix it'. ^nil].
	(PopUpMenu confirm: 'Really convert ', 
							aCodePackage packageName, 
							' to an Environment?')
	ifFalse: [ ^ nil ]
	ifTrue: [ ^ self new fromCodePackage: aCodePackage ]
! !

!Environment class methodsFor: 'instance creation' stamp: 'KenD 6/9/2020 15:31:56'!
fromFeature: aString
	"Similar to Feature>>require: but (sub)Class names are not
	 registed in dictionary Smalltalk.
	 Answer a new Environment."
	| existingCodePackage | 
	existingCodePackage :=
		 CodePackage packageOfSystemCategory: aString 
						ifNone: [ ^self new fromFeature: aString].
	^ self fromCodePackage: existingCodePackage 
	! !

!Environment class methodsFor: 'instance creation' stamp: 'KenD 6/12/2020 14:31:01'!
newNamed: aString
	"Answer a new Environment with packageName aString and enter into Smalltalk"
	| envName newEnv |
	envName := aString asEnvironmentName ifFalse: [^ self error: 'invalid environment name'].
	(Smalltalk includesKey: envName asSymbol) ifTrue: [^ self error: 'global ', envName, 'already exists'].
	newEnv := self new name: envName asSymbol packageName: aString.
	^ Smalltalk at: envName put: newEnv! !

!ProtoObject methodsFor: '*system-environments' stamp: 'Install-Morph-MetaProperties 6/15/2020 14:21:30'!
package

	^nil
	! !

!CodeProvider methodsFor: '*system-environments' stamp: 'KenD 6/11/2020 00:17:55'!
annotationForSelector: aSelector ofClass: aClass 
	"Provide a line of content for an annotation pane, representing  
	information about the given selector and class"
	"Nota Bene: replaces base system method"
	| stamp sendersCount implementorsCount aCategory separator aString aList aComment stream requestList |
	aSelector == #Comment
		ifTrue: [^ self annotationForClassCommentFor: aClass].
	aSelector == #Definition
		ifTrue: [^ self annotationForClassDefinitionFor: aClass].
	aSelector == #Hierarchy
		ifTrue: [^ self annotationForHierarchyFor: aClass].
	stream _ WriteStream on: String new.
	requestList _ self annotationRequests.
	separator _ self annotationSeparator.
	requestList
		do: [:aRequest | 
			aRequest == #firstComment
				ifTrue: [
					aComment _ aClass firstCommentAt: aSelector.
					aComment isEmptyOrNil
						ifFalse: [stream position = 0 ifFalse: [stream nextPutAll: separator].
								stream nextPutAll: aComment]].
			aRequest == #masterComment
				ifTrue: [
					aComment _ aClass supermostPrecodeCommentFor: aSelector.
					aComment isEmptyOrNil
						ifFalse: [stream position = 0 ifFalse: [stream nextPutAll: separator].
								stream nextPutAll: aComment]].
			aRequest == #documentation
				ifTrue: [
					aComment _ aClass precodeCommentOrInheritedCommentFor: aSelector.
					aComment isEmptyOrNil
						ifFalse: [stream isEmpty ifFalse: [stream nextPutAll: separator].
								stream nextPutAll: aComment]].
			aRequest == #timeStamp
				ifTrue: [
					stamp _ self timeStamp.
					stream isEmpty ifFalse: [stream nextPutAll: separator].
					stream nextPutAll: (stamp size > 0 ifTrue: [stamp] ifFalse: ['no timestamp'])].
			aRequest == #messageCategory
				ifTrue: [
					aCategory _ aClass organization categoryOfElement: aSelector.
					aCategory
						ifNotNil: ["woud be nil for a method no longer present,  
							e.g. in a recent-submissions browser"
							stream isEmpty ifFalse: [stream nextPutAll: separator].
							stream nextPutAll: aCategory]].
			aRequest == #sendersCount
				ifTrue: [
					sendersCount _ Smalltalk numberOfSendersOf: aSelector.
					sendersCount _ sendersCount = 1
								ifTrue: ['1 sender']
								ifFalse: [sendersCount printString , ' senders'].
					stream isEmpty ifFalse: [stream nextPutAll: separator].
					stream nextPutAll: sendersCount].
			aRequest == #implementorsCount
				ifTrue: [
					implementorsCount _ Smalltalk numberOfImplementorsOf: aSelector.
					implementorsCount _ implementorsCount = 1
								ifTrue: ['1 implementor']
								ifFalse: [implementorsCount printString , ' implementors'].
					stream isEmpty ifFalse: [stream nextPutAll: separator].
					stream nextPutAll: implementorsCount].
			aRequest == #priorVersionsCount
				ifTrue: [
					stream isEmpty ifFalse: [stream nextPutAll: separator].
					self
						addPriorVersionsCountForSelector: aSelector
						ofClass: aClass
						to: stream].
			aRequest == #priorTimeStamp
				ifTrue: [
					stamp _ VersionsBrowser
								timeStampFor: aSelector
								class: aClass
								reverseOrdinal: 2.
					stamp
						ifNotNil: [stream isEmpty ifFalse: [stream nextPutAll: separator].
							stream nextPutAll: 'prior timestamp: ' , stamp]].
			aRequest == #packages
				ifTrue: [
					(aClass compiledMethodAt: aSelector ifAbsent: nil) ifNotNil: [ :cm |
						stream isEmpty ifFalse: [stream nextPutAll: separator].
						((aClass isKindOf: Class) 
							ifTrue: [aClass package] 
							ifFalse: [CodePackage packageOfMethod: cm  methodReference 
													ifNone: nil]
						)
							ifNil: [ stream nextPutAll: 'in no package' ]
							ifNotNil: [ :codePackage |
								stream nextPutAll: 'in package '; nextPutAll: codePackage packageName ]]].
			aRequest == #changeSets
				ifTrue: [
					stream isEmpty ifFalse: [stream nextPutAll: separator].
					aList _ ChangeSet allChangeSetsWithClass: aClass selector: aSelector.
					aList size > 0
						ifTrue: [aList size = 1
								ifTrue: [stream nextPutAll: 'only in change set']
								ifFalse: [stream nextPutAll: 'in change sets:'].
							aList
								do: [:aChangeSet | stream nextPut: Character space; nextPutAll: aChangeSet name ]
								separatedBy: [ stream nextPut: $, ]]
						ifFalse: [stream nextPutAll: 'in no change set']].
			aRequest == #allChangeSets
				ifTrue: [
					stream isEmpty ifFalse: [stream nextPutAll: separator].
					aList _ ChangeSet allChangeSetsWithClass: aClass selector: aSelector.
					aList size > 0
						ifTrue: [aList size = 1
								ifTrue: [stream nextPutAll: 'only in change set']
								ifFalse: [stream nextPutAll: 'in change sets:'].
							aList
								do: [:aChangeSet | stream nextPut: Character space; nextPutAll: aChangeSet name ]
								separatedBy: [ stream nextPut: $, ]]
						ifFalse: [stream nextPutAll: 'in no change set']].
			aRequest == #allBaseSystemChangeSets
				ifTrue: [
					stream isEmpty ifFalse: [stream nextPutAll: separator].
					aList _ (ChangeSet allChangeSetsWithClass: aClass selector: aSelector) select: [ :it | it isForBaseSystem ].
					aList size > 0
						ifTrue: [
							aList size = 1
								ifTrue: [stream nextPutAll: 'only in base system change set']
								ifFalse: [stream nextPutAll: 'in base system change sets:'].
							aList
								do: [:aChangeSet | stream nextPut: Character space; nextPutAll: aChangeSet name ]
								separatedBy: [ stream nextPut: $, ]]
						ifFalse: [stream nextPutAll: 'in no base system change set']].
			aRequest == #closuresInfo
				ifTrue: [
					aString _ aClass closuresInfoAt: aSelector.
					aString size > 0
						ifTrue: [stream isEmpty ifFalse: [stream nextPutAll: separator].
								stream nextPutAll: aString]].
		].
	^ stream contents! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 21:24:26'!
environment
	^ selectedSystemCategory 
		ifNil: [Smalltalk] 
		ifNotNil: [Smalltalk environmentFromSystemCategory: selectedSystemCategory]! !

!Browser methodsFor: '*system-environments' stamp: 'len 6/11/2020 09:26:22'!
hierarchicalClassList

	"classNames are an arbitrary collection of classNames of the system.
	Reorder those class names so that they are sorted and indended by inheritance"

	| classes environment |

	"Creating the hierarchy is *really slow* for the full class list. Skip it for now."
	selectedSystemCategory = SystemOrganizer allCategory ifTrue: [^ self defaultClassList].
	environment _ self environment.
	classes _ self defaultClassList collect: [:sym | environment at: sym].
	^ self
		flattenHierarchyTree: (self createHierarchyTreeOf: classes)
		on: OrderedCollection new
		indent: ''! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 7/3/2020 14:57:03'!
potentialClassNames
	"Answer the names of all the classes that could be viewed in this browser.  This hook is provided so that HierarchyBrowsers can indicate their restricted subset.  For generic Browsers, the entire list of classes known to Smalltalk is provided, though of course that really only is accurate in the case of full system browsers."
	"NB: replaces base system method"
	| allCassNames |
	allCassNames :=  Smalltalk classNames asSet.
	Environment allInstancesDo: [ :env | 
		allCassNames  addAll: (env collect: [ :aClass | (env name asString , ' @ ', aClass name asString) asSymbol ])
	].
	^allCassNames asOrderedCollection
	! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 21:47:39'!
selectedClass
	"Answer the class that is currently selected. Answer nil if no selection exists."
	"Nota Bene: replaces method in base system"
	| name env |
	(name _ self selectedClassName) ifNil: [^ nil].
	env := self environment.
	(env == Smalltalk)
	ifTrue: [
	^ self environment at: name 
			ifAbsent: [nil]
	]
	ifFalse: [
		^self environment at: name 
			ifAbsent: [
				Smalltalk at: name
							ifAbsent: [nil]
			]
	]! !

!HierarchyBrowser methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 21:34:00'!
classList
	"Nota Bene: replaces base system method"
	| env |
	env _ self environment.
	(env == Smalltalk)
	ifTrue: [
		classList _ classList select: [:each | 
		env includesKey: each withoutLeadingBlanks asSymbol].
	]
	ifFalse: [
		classList _ classList select: [:each | |lookupName|
			lookupName := each withoutLeadingBlanks asSymbol.
			(env includesKey: lookupName)
			 or: [Smalltalk includesKey: lookupName]].
	].
	^ classList! !

!HierarchyBrowser methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 06:52:10'!
environment

	^ centralClass ifNil: [super environment] ifNotNil: [centralClass environment]! !

!CodeFileBrowser methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 02:14:24'!
baseCodeSource
	^ baseCodeSource ifNil: [ self environment ]! !

!CodeFileBrowser methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 02:14:19'!
caseCodeSource
	^ caseCodeSource ifNil: [ self environment ]! !

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

!ChangeSorter methodsFor: '*system-environments' stamp: 'KenD 6/17/2020 14:49:20'!
selectedClassOrMetaClass
	"Careful, the class may have been removed!!"
	"Nota Bene: overwrites base system method"

	| cName cEnv |
	currentClassName ifNil: [^ nil].
	cEnv := myChangeSet codePackage  ifNotNil: [ :pkg | pkg environment ] ifNil: [Smalltalk].
	(currentClassName endsWith: ' class')
		ifTrue: [
			cName _ (currentClassName copyFrom: 1 to: currentClassName size-6) asSymbol.
			^ (cEnv at: cName ifAbsent: [^nil]) class]
		ifFalse: [
			cName _ currentClassName asSymbol.
			^ cEnv at: cName ifAbsent: nil]! !

!UndefinedObject methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 05:29:21'!
environment

	^Smalltalk! !

!UndefinedObject methodsFor: '*system-environments' stamp: 'KenD 6/30/2020 13:42:54'!
environmentsExportMe

	^false! !

!ClassDescription methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 05:40:49'!
sharedPoolsString
	"Answer a string of my shared pool names separated by spaces."

	^String streamContents: [ :stream |
		self sharedPools 
			do: [ :each |
				(each is: #Environment)
				ifFalse: [
				stream nextPutAll: (Smalltalk
					keyAtIdentityValue: each 
					ifAbsent: [ 'private' ]) ]
			]
			separatedBy: [ stream space ] ]! !

!Class methodsFor: '*system-environments' stamp: 'KenD 6/16/2020 13:21:25'!
environment
	"Answer either Smalltalk or the _first _ Environment instance in my sharedPool"
	^self sharedPools detect: [ :p | p is: #Environment ] ifNone: [ Smalltalk ]! !

!Class methodsFor: '*system-environments' stamp: 'KenD 6/16/2020 15:57:40'!
environmentsExportMe
	"If in an Environment do NOT register my name in  the Smalltalk SystemDictionary"
	^false! !

!Class methodsFor: '*system-environments' stamp: 'KenD 6/20/2020 15:50:42'!
fileOutPool: aPool onFileStream: aFileStream 
	"Nota Bene: I replace a basic system method"
	| aPoolName |
	(aPool  isKindOf: SharedPool class) ifTrue:[^self notify: 'we do not fileout SharedPool type shared pools for now'].
	(aPool  is: #Environment) ifTrue:[^self notify: 'we do not fileout SharedPool Environments'].
	aPoolName _ self environment keyAtIdentityValue: aPool.
	Transcript newLine; show: aPoolName.
	aFileStream nextPutAll: 'Transcript show: ''' , aPoolName , '''; newLine!!'; newLine.
	aFileStream nextPutAll: 'Smalltalk at: #' , aPoolName , ' put: Dictionary new!!'; newLine.
	aPool keys sort do: [ :aKey | | aValue |
		aValue _ aPool at: aKey.
		aFileStream nextPutAll: aPoolName , ' at: #''' , aKey asString , '''', ' put:  '.
		aValue isNumber
			ifTrue: [ aValue printOn: aFileStream ]
			ifFalse: [
				aFileStream nextPutAll: '('.
				aValue printOn: aFileStream.
				aFileStream nextPutAll: ')' ].
		aFileStream nextPutAll: '!!'; newLine ].
	aFileStream newLine! !

!Class methodsFor: '*system-environments' stamp: 'KenD 6/18/2020 13:35:38'!
isObsolete
	"Return true if the receiver is obsolete."
	"Nota Bene: I replace a basic system method"
	^(self environment at: name ifAbsent: nil) ~~ self! !

!Class methodsFor: '*system-environments' stamp: 'KenD 6/20/2020 15:52:35'!
rename: aString
	"The new name of the receiver is the argument, aString."
	"Nota Bene: I replace base system method"
	| newName |
	(newName _ aString asSymbol) ~= self name
		ifFalse: [^ self].
	(self environment includesKey: newName)
		ifTrue: [^ self error: newName , ' already exists'].
	(Undeclared includesKey: newName)
		ifTrue: [self inform: 'There are references to, ' , aString printString , '
from Undeclared. Check them after this change.'].

	self safeRenameTo: newName.! !

!Class methodsFor: '*system-environments' stamp: 'KenD 6/11/2020 13:21:25'!
shouldFileOutPool: aPoolName
	"respond with true if the user wants to file out aPoolName"
	"Nota Bene: I replace base system method"
	| aPool |
	aPool := self sharedPools detect: [:pool | (pool is: #Environment) and: [pool name = aPoolName]] ifNone:[nil].
	aPool ifNotNil: [^false]. "Don't fileout Environments"
	^self confirm: ('FileOut the sharedPool ', aPoolName, '?')! !

!Metaclass methodsFor: '*system-environments' stamp: 'KenD 6/16/2020 13:22:06'!
environment

	^ thisClass environment! !

!Metaclass methodsFor: '*system-environments' stamp: 'KenD 6/16/2020 13:26:18'!
package

	^ thisClass package! !

!Categorizer methodsFor: '*system-environments' stamp: 'len 6/12/2020 08:50:54'!
classesAt: aCategoryName
	"Nota Bene: I replace a base system method."
	
	| environment |
	environment _ Smalltalk environmentFromSystemCategory: aCategoryName.
	^(self listAtCategoryNamed: aCategoryName) collect: [:aClassName | environment at: aClassName asSymbol ]! !

!Categorizer methodsFor: '*system-environments' stamp: 'KenD 7/5/2020 13:16:22'!
listAtCategoryNamed: categoryName
	"Answer the array of elements associated with the name, categoryName."
	"Nota Bene: I replace a base system method"
	| environment |
	environment  _ Smalltalk at: ((categoryName asIdentifier: true) asSymbol) ifAbsent: [nil].
	((environment notNil and: [environment is: #Environment] ) and: [self isKindOf: SystemOrganizer])
		ifTrue: [ ^ environment keys ]
		ifFalse: [| index | 
			index _ categoryArray indexOf: categoryName ifAbsent: [^Array new].
			^ self listAtCategoryNumber: index
		]! !

!SystemDictionary methodsFor: '*system-environments' stamp: 'KenD 6/30/2020 13:55:14'!
environmentsExportMe

	^false! !

!CodePackage methodsFor: '*system-environments' stamp: 'KenD 6/11/2020 02:11:48'!
classesDo: aBlock
	"Nota Bene: this overwrites base system method"
	| env |
	env := self environment.
	self systemCategories do: [ :cat |
		(SystemOrganization listAtCategoryNamed: cat) do: [ :className |
			aBlock value: (env at: className) ]]! !

!CodePackage methodsFor: '*system-environments' stamp: 'len 6/12/2020 08:37:45'!
environment
	"Answer the Environment for the classes in this package, or Smalltalk if the package is not isolated."
	^ Smalltalk environmentFromSystemCategory: self systemCategoryPrefix! !

!BrowserWindow class methodsFor: '*system-environments' stamp: 'KenD 7/3/2020 15:56:00'!
findClassFrom: potentialClassNames ifFound: aBlock
	"NB: replaces base system method"
	| classNames exactMatch foundClass index toMatch |
	self  classNameRequester request: self findClassDialogTitle initialAnswer: '' do: [:pattern|
		pattern isEmpty
			ifTrue: [self flash]
			ifFalse: 
				[toMatch _ (pattern copyWithout: $.) asLowercase withBlanksTrimmed.
				classNames _ (pattern last = $. or: [pattern last = $ ])
					ifTrue: [potentialClassNames select: [:nm |  nm asLowercase = toMatch]]
					ifFalse: [potentialClassNames select: [:n | n includesSubstring: toMatch caseSensitive: false]].
				classNames isEmpty
					ifTrue: [self flash]
					ifFalse:
						[exactMatch _ classNames detect: [ :each | each asLowercase = toMatch] ifNone: nil.

						index _ classNames size = 1
							ifTrue: [ 1 ]
							ifFalse: [ exactMatch
								ifNil: [(PopUpMenu labelArray: classNames lines: #()) startUpMenu]
								ifNotNil: [classNames addFirst: exactMatch.
									(PopUpMenu labelArray: classNames lines: #(1)) startUpMenu]].

						index = 0
							ifTrue: [self flash]
							ifFalse: [ | nameSym |
								nameSym _ classNames at: index.
								(nameSym asString includes: $@)
								  	ifFalse: [foundClass _ Smalltalk at: nameSym asSymbol]
								  	ifTrue: [|tokens env |
										tokens _ nameSym asString findTokens: ' '.
									 	env _  Smalltalk at:  tokens first asSymbol ifAbsent: [self flash. ^nil].
									 	foundClass _ env at: tokens last asSymbol ifAbsent: [self flash. ^nil].
									].
								aBlock value: foundClass
							]]]].! !

!MethodReference methodsFor: '*system-environments' stamp: 'KenD 6/28/2020 15:39:18'!
actualClassIfAbsent: anAbsentBlock 
	"Nota Bene: replaced basr system metrhod"
	^(self environment) 
		at: classSymbol 
		ifPresent: [ :actualClass |
			classIsMeta
				ifTrue: [ actualClass class ]
				ifFalse: [ actualClass ] ]
		ifAbsent: anAbsentBlock 
! !

!MethodReference methodsFor: '*system-environments' stamp: 'KenD 6/28/2020 15:40:09'!
environment

	^categoryName 
		ifNil: [ Smalltalk ]
		ifNotNil:  [ Smalltalk environmentFromSystemCategory: categoryName ]! !

!MethodReference methodsFor: '*system-environments' stamp: 'KenD 6/28/2020 15:43:44'!
setClass: aClass methodSymbol: methodSym stringVersion: aString
	"Nota Bene: replaces base system method"
	categoryName := (aClass environment is: #Environment)
		ifTrue:  [aClass environment packageName]
		ifFalse: [nil].
	self
		setClassSymbol: aClass theNonMetaClass name
		classIsMeta: aClass isMeta
		methodSymbol: methodSym
		stringVersion: aString! !

!ChangeSet methodsFor: '*system-environments' stamp: 'KenD 6/21/2020 13:30:33'!
changedClasses
	"Answer an OrderedCollection of changed or edited classes.
	Does not include removed classes.  Sort alphabetically by name."
	"Nota Bene: replaces base system method."
	"Much faster to sort names first, then convert back to classes.  Because metaclasses reconstruct their name at every comparison in the sorted collection.
	8/91 sw chgd to filter out non-existent classes (triggered by problems with class-renames"
 
	^ self changedClassNames
		collect: [:className | codePackage environment classNamed: className]
		thenSelect: [:aClass | aClass notNil]! !

!ChangeSet class methodsFor: '*system-environments' stamp: 'KenD 6/16/2020 13:26:47'!
methodAdded: aCompiledMethod selector: aSymbol inProtocol: aCategoryName class: aClass requestor: requestor

	| packageOrNil |
	
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	
	packageOrNil _ (((aClass isKindOf: Class)  or: [aClass isKindOf: Metaclass])
							ifTrue: [aClass package] 
							ifFalse: [CodePackage packageOfMethod: aCompiledMethod  methodReference 
													ifNone: nil]
						).
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet
			methodAdded: aCompiledMethod
			selector: aSymbol
			inProtocol: aCategoryName
			class: aClass
			requestor: requestor ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ]! !

!ChangeSet class methodsFor: '*system-environments' stamp: 'KenD 6/11/2020 01:26:30'!
methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass requestor: requestor

	| packageOrNil |
	
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	
	packageOrNil _ ((aClass isKindOf: Class) 
							ifTrue: [aClass package] 
							ifFalse: [CodePackage packageOfMethod: newMethod  methodReference 
													ifNone: nil]
						).
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet
			methodChangedFrom: oldMethod
			to: newMethod
			selector: aSymbol
			inClass: aClass
			requestor: requestor ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ]! !
