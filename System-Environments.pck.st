'From Cuis 5.0 [latest update: #4213] on 10 June 2020 at 2:58:19 pm'!
'Description Environments are associated with packaged Features, whose Class NameSpace is disjoint from Smalltalk.

This allows importing multiple Feature/Package Classes with the same name.
'!
!provides: 'System-Environments' 1 11!
!requires: 'Cuis-Base' 50 4208 nil!
SystemOrganization addCategory: #'System-Environments'!


!classDefinition: #Environment category: #'System-Environments'!
IdentityDictionary subclass: #Environment
	instanceVariableNames: 'name codePackage color'
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

!Environment methodsFor: 'accessing' stamp: 'KenD 6/8/2020 08:19:50'!
@ classNameSymbol

	^ self at: classNameSymbol ! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/9/2020 20:36:53'!
at: aSymbol

	^ self at: aSymbol ifAbsent: [ Smalltalk at: aSymbol ]! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/10/2020 07:06:09'!
at: aSymbol ifAbsent: absentBlock

	^ super at: aSymbol ifAbsent: [ Smalltalk at: aSymbol ifAbsent: absentBlock ]! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/9/2020 09:38:09'!
codePackage

	^codePackage! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/9/2020 15:30:31'!
icon
	"Answer a 16x16 color swatch"
	^color icon! !

!Environment methodsFor: 'accessing' stamp: 'KenD 6/9/2020 20:50:06'!
includesKey: key 
	"Answer whether the receiver has a key equal to the argument, key."
	
	self at: key ifAbsent: [^Smalltalk includesKey: key].
	^true! !

!Environment methodsFor: 'testing' stamp: 'KenD 6/9/2020 14:34:11'!
is: aSymbol
	^ aSymbol == #Environment or: [ super is: aSymbol ]! !

!Environment methodsFor: 'instance creation' stamp: 'KenD 6/10/2020 15:05:42'!
fromCodePackage: aCodePackage
	"Convert from an already filed in Feature/Package.
	 Answer a new Environment."
	
	name := aCodePackage packageName asEnvironmentName asSymbol.
	codePackage := aCodePackage.
	"The basic difference is registration of Classes"
	codePackage classesDo: [ :cls |
		self at: cls name put: cls.
		cls addSharedPool: self.
		Smalltalk removeKey: cls name ifAbsent: [ nil ].
	].
	Smalltalk at:  name put: self
! !

!Environment methodsFor: 'instance creation' stamp: 'KenD 6/9/2020 09:03:14'!
fromFeature: aString
	"Similar to Feature>>require: but (sub)Class names are not
	 registed in dictionary Smalltalk.
	 Answer a new Environment."
	self notYetImplemented ! !

!Environment methodsFor: 'instance creation' stamp: 'KenD 6/9/2020 15:28:59'!
initialize

	color _ Color random! !

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

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 15:04:10'!
environment
	| env |
	selectedSystemCategory ifNil: [ ^Smalltalk ].
	env _ Smalltalk at: (selectedSystemCategory asEnvironmentName asSymbol) ifAbsent: [ nil ].
	^((env notNil) and: [ env is: #Environment ]) ifTrue: [ env ] ifFalse: [Smalltalk]! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 15:04:35'!
hierarchicalClassList

	"classNames are an arbitrary collection of classNames of the system.
	Reorder those class names so that they are sorted and indended by inheritance"

	| classes |

	"Creating the hierarchy is *really slow* for the full class list. Skip it for now."
	selectedSystemCategory = SystemOrganizer allCategory ifTrue: [^ self defaultClassList].
	(self isBrowsingEnvironment)
		ifTrue:  [ | env |
			env := Smalltalk at: (selectedSystemCategory asEnvironmentName asSymbol) ifAbsent: [ nil ].
			classes := env ifNotNil: [ env values ] ifNil: [ Array new ].
		 ]
		ifFalse: [ classes := self defaultClassList collect: [:sym | Smalltalk classNamed: sym]].
	
	^ self
		flattenHierarchyTree: (self createHierarchyTreeOf: classes)
		on: OrderedCollection new
		indent: ''.! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 15:04:56'!
isBrowsingEnvironment
	"Am I looking at Environment/NameSpace Classes or Smalltalk registered Classes?"

	| possibleEnvironment |
	selectedSystemCategory ifNil: [ ^false ].
	possibleEnvironment _ Smalltalk at: (selectedSystemCategory asEnvironmentName asSymbol) 
							ifAbsent: [ ^false ].
	^ (possibleEnvironment is: #Environment)! !

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

!Categorizer methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 15:05:14'!
classesAt: aCategoryName
	"Nota Bene: I replace a base system method."
	
	| environment |
	environment _ Smalltalk at: (aCategoryName asEnvironmentName asSymbol) ifAbsent: [ nil ].
	^environment 
		ifNil: [(self listAtCategoryNamed: aCategoryName) 
							collect: [:aClassName | Smalltalk classNamed: aClassName] 
		]
		ifNotNil: [ environment values ]  
	
		! !

!Categorizer methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 15:05:26'!
listAtCategoryNamed: categoryName
	"Answer the array of elements associated with the name, categoryName."
	"Nota Bene: I replace a base system method"
	| environment  |
	environment  _ Smalltalk at: (categoryName asEnvironmentName asSymbol) ifAbsent: [nil].
	(environment notNil and: [environment is: #Environment] )
		ifTrue: [ ^ environment keys ]
		ifFalse: [| i | 
			i _ categoryArray indexOf: categoryName ifAbsent: [^Array new].
			^ self listAtCategoryNumber: i 
		]! !

!String methodsFor: '*system-environments' stamp: 'KenD 6/10/2020 14:57:51'!
asEnvironmentName
  "I am a catargory name. Answer me with hyphens removed but keep first char as uppercase"

	^ self asIdentifier: true! !

!SystemDictionary methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 15:40:51'!
icon

	^ Color transparent icon! !
