'From Cuis 5.0 [latest update: #4219] on 11 June 2020 at 12:18:06 am'!
'Description Environments are associated with packaged Features, whose class namespace is disjoint from Smalltalk.

This allows importing multiple Feature/Package Classes with the same name.
'!
!provides: 'System-Environments' 1 24!
!requires: 'Cuis-Base' 50 4208 nil!
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

!Environment methodsFor: 'printing' stamp: 'len 6/12/2020 08:22:40'!
printOn: aStream
	aStream nextPutAll: self name; nextPutAll: ' environment'! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/8/2020 08:19:50'!
@ classNameSymbol

	^ self at: classNameSymbol ! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/12/2020 14:24:54'!
package

	^ (self packageName) 
		ifNotNil: [ :pkgName | CodePackage installedPackages at: pkgName ifAbsent: []]
		ifNil: [ CodePackage installedPackages detect: [:one| one environment == self] ifNone: [] ]! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/12/2020 13:37:05'!
packageName

	^packageName! !

!Environment methodsFor: 'error handling' stamp: 'len 6/11/2020 08:10:53'!
doesNotUnderstand: aMessage
	^ self at: aMessage selector ifAbsent: [super doesNotUnderstand: aMessage]
	! !

!Environment methodsFor: 'initialization' stamp: 'KenD 6/12/2020 15:35:23'!
fromCodePackage: aCodePackage
	"Convert from an already filed in Feature/Package.
	 Answer a new Environment."
	
	packageName := aCodePackage packageName.
	name := packageName asEnvironmentName asSymbol.
	"The basic difference is registration of Classes"
	aCodePackage classesDo: [ :cls |
		self declare: cls name from: Smalltalk.
		cls addSharedPool: self.
	].
	Smalltalk at: name put: self
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

!Environment methodsFor: 'testing' stamp: 'KenD 6/9/2020 14:34:11'!
is: aSymbol
	^ aSymbol == #Environment or: [ super is: aSymbol ]! !

!Environment class methodsFor: 'instance creation' stamp: 'KenD 6/9/2020 12:56:06'!
fromCodePackage: aCodePackage
	"Convert from an already filed in Feature/Package.
	 Answer a new Environment."
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

!Class methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 16:38:38'!
environment
	"Answer either Smalltalk or _the_ Environment instance in my sharedPool"
	^self sharedPools detect: [ :p | p is: #Environment ] ifNone: [ Smalltalk ]! !

!Categorizer methodsFor: '*system-environments' stamp: 'len 6/12/2020 08:50:54'!
classesAt: aCategoryName
	"Nota Bene: I replace a base system method."
	
	| environment |
	environment _ Smalltalk environmentFromSystemCategory: aCategoryName.
	^(self listAtCategoryNamed: aCategoryName) collect: [:aClassName | environment at: aClassName asSymbol ]! !

!Categorizer methodsFor: '*system-environments' stamp: 'KenD 6/12/2020 13:42:26'!
listAtCategoryNamed: categoryName
	"Answer the array of elements associated with the name, categoryName."
	"Nota Bene: I replace a base system method"
	| environment  |
	environment  _ Smalltalk at: ((categoryName asIdentifier: true) asSymbol) ifAbsent: [nil].
	(environment notNil and: [environment is: #Environment] )
		ifTrue: [ ^ environment keys ]
		ifFalse: [| i | 
			i _ categoryArray indexOf: categoryName ifAbsent: [^Array new].
			^ self listAtCategoryNumber: i 
		]! !

!String methodsFor: '*system-environments' stamp: 'len 6/12/2020 07:17:16'!
asEnvironmentName
	"I am a system catargory name or a package name.
	Answer an adequate name for an environment, e.g. hyphens removed and first character uppercase."

	^ self asIdentifier: true! !

!SystemDictionary methodsFor: '*system-environments' stamp: 'len 6/12/2020 08:25:55'!
environmentFromSystemCategory: aString
	| subcategory name i |
	subcategory _ aString.
	[name _ subcategory asEnvironmentName asSymbol.
	self at: name ifPresent: [:anObject| (anObject is: #Environment) ifTrue: [^ anObject]].
	(i _ subcategory findLast: [:one| one = $-]) = 0] whileFalse:
	[subcategory _ subcategory copyFrom: 1 to: i-1].
	^ self! !

!SystemDictionary methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 15:40:51'!
icon

	^ Color transparent icon! !

!SystemDictionary methodsFor: '*system-environments' stamp: 'len 6/11/2020 08:29:14'!
name
	^ #Smalltalk! !

!CodePackage methodsFor: '*system-environments' stamp: 'len 6/12/2020 08:37:45'!
environment
	"Answer the Environment for the classes in this package, or Smalltalk if the package is not isolated."
	^ Smalltalk environmentFromSystemCategory: self systemCategoryPrefix! !

!CodePackage methodsFor: '*system-environments' stamp: 'KenD 6/12/2020 14:42:46'!
isolate
	"If the package classes are in the global Smalltalk environment, create a new environment corresponding to this package name and move all classes to the new environment, and answer the new enviroment. If the environment was already created, answer the existing environment."
	| environment |
	(environment _ self environment) == Smalltalk ifFalse: [^ environment].
	(PopUpMenu confirm: 'Really move classes in ', self packageName, ' to a new Environment?')
		ifFalse: [^ environment].
	^ Environment new fromCodePackage: self! !
