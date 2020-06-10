'From Cuis 5.0 [latest update: #4213] on 12 June 2020 at 9:19:59 am'!
'Description Environments are associated with packaged Features, whose class namespace is disjoint from Smalltalk.

This allows importing multiple Feature/Package Classes with the same name.
'!
!provides: 'System-Environments' 1 17!
!requires: 'Cuis-Base' 50 4208 nil!
SystemOrganization addCategory: #'System-Environments'!


!classDefinition: #Environment category: #'System-Environments'!
IdentityDictionary subclass: #Environment
	instanceVariableNames: 'name'
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

!Environment methodsFor: 'accessing' stamp: 'len 6/12/2020 09:06:27'!
package
	^ CodePackage installedPackages detect: [:one| one environment == self] ifNone: []! !

!Environment methodsFor: 'error handling' stamp: 'len 6/11/2020 08:10:53'!
doesNotUnderstand: aMessage
	^ self at: aMessage selector ifAbsent: [super doesNotUnderstand: aMessage]
	! !

!Environment methodsFor: 'initialization' stamp: 'len 6/12/2020 08:40:10'!
name: aString
	name _ aString asSymbol! !

!Environment methodsFor: 'testing' stamp: 'KenD 6/9/2020 14:34:11'!
is: aSymbol
	^ aSymbol == #Environment or: [ super is: aSymbol ]! !

!Environment class methodsFor: 'instance creation' stamp: 'len 6/12/2020 07:35:20'!
newNamed: aString
	aString = aString asEnvironmentName ifFalse: [^ self error: 'invalid environment name'].
	name _ aString asSymbol.
	(Smalltalk includesKey: name) ifTrue: [^ self error: 'global ', name printString, 'already exists'].
	^ Smalltalk at: name put: (self new name: name)! !

!Browser methodsFor: '*system-environments' stamp: 'len 6/11/2020 08:43:56'!
environment
	^ selectedSystemCategory ifNil: [Smalltalk] ifNotNil: [Smalltalk environmentFromSystemCategory: selectedSystemCategory]! !

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

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 15:24:38'!
selectedClass
	"Answer the class that is currently selected. Answer nil if no selection exists."
	"Nota Bene: replaces method in base system"
	| name |
	(name _ self selectedClassName) ifNil: [^ nil].
	^ self environment at: name ifAbsent: nil! !

!HierarchyBrowser methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 16:14:21'!
classList
	"Nota Bene: replaces base system method"
	| env |
	env _ self environment.
	classList _ classList select: [:each | env includesKey: each withoutLeadingBlanks asSymbol].
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

!CodePackage methodsFor: '*system-environments' stamp: 'len 6/12/2020 09:11:31'!
isolate
	"If the package classes are in the global Smalltalk environment, create a new environment corresponding to this package name and move all classes to the new environment, and answer the new enviroment. If the environment was already created, answer the existing environment."
	| environment |
	(environment _ self environment) == Smalltalk ifFalse: [^ environment].
	(PopUpMenu confirm: 'Really move classes in ', self packageName, ' to a new Environment?')
		ifFalse: [^ environment].
	environment _ Environment newNamed: self systemCategoryPrefix asEnvironmentName.
	self classesDo: [:each|
		environment declare: each name from: Smalltalk.
		each addSharedPool: environment].
	^ environment! !
