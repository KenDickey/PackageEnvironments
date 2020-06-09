'From Cuis 5.0 [latest update: #4213] on 9 June 2020 at 3:24:51 pm'!
'Description Environments are associated with packaged Features, whose Class NameSpace is disjoint from Smalltalk.

This allows importing multiple Feature/Package Classes with the same name.
'!
!provides: 'System-Environments' 1 5!
!requires: 'Cuis-Base' 50 4208 nil!
SystemOrganization addCategory: #'System-Environments'!


!classDefinition: #Environment category: #'System-Environments'!
IdentityDictionary subclass: #Environment
	instanceVariableNames: 'name codePackage'
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

!Environment methodsFor: 'accessing' stamp: 'KenD 6/9/2020 09:38:09'!
codePackage

	^codePackage! !

!Environment methodsFor: 'testing' stamp: 'KenD 6/9/2020 14:34:11'!
is: aSymbol
	^ aSymbol == #Environment or: [ super is: aSymbol ]! !

!Environment methodsFor: 'instance creation' stamp: 'KenD 6/9/2020 12:57:49'!
fromCodePackage: aCodePackage
	"Convert from an already filed in Feature/Package.
	 Answer a new Environment."
	
	name := (aCodePackage packageName asIdentifier: true) asSymbol.
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

!Environment class methodsFor: 'instance creation' stamp: 'KenD 6/9/2020 09:10:21'!
fromFeature: aString
	"Similar to Feature>>require: but (sub)Class names are not
	 registed in dictionary Smalltalk.
	 Answer a new Environment."
	| existingCodePackage | 
	existingCodePackage :=
		 CodePackage packageOfSystemCategory: aString 
						ifNone: [ ^self new fromFeature: aString].
	^ self new fromCodePackage: existingCodePackage 
	! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 15:24:33'!
environment

	selectedSystemCategory ifNil: [ ^Smalltalk ].
	^Smalltalk at: ((selectedSystemCategory asIdentifier: true) asSymbol) ifAbsent: [ Smalltalk ].! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 14:38:42'!
hierarchicalClassList

	"classNames are an arbitrary collection of classNames of the system.
	Reorder those class names so that they are sorted and indended by inheritance"

	| classes |

	"Creating the hierarchy is *really slow* for the full class list. Skip it for now."
	selectedSystemCategory = SystemOrganizer allCategory ifTrue: [^ self defaultClassList].
	(self isBrowsingEnvironment)
		ifTrue:  [ | env |
			env := Smalltalk at: ((selectedSystemCategory asIdentifier: true) asSymbol) ifAbsent: [ nil ].
			classes := env ifNotNil: [ env values ] ifNil: [ Array new ].
		 ]
		ifFalse: [ classes := self defaultClassList collect: [:sym | Smalltalk classNamed: sym]].
	
	^ self
		flattenHierarchyTree: (self createHierarchyTreeOf: classes)
		on: OrderedCollection new
		indent: ''.! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 14:55:07'!
isBrowsingEnvironment
	"Am I looking at Environment/NameSpace Classes or Smalltalk registered Classes?"

	| possibleEnvironment |
	selectedSystemCategory ifNil: [ ^false ].
	possibleEnvironment _ Smalltalk at: ((selectedSystemCategory asIdentifier: true) asSymbol) 
							ifAbsent: [ ^false ].
	^ (possibleEnvironment is: #Environment)! !

!Browser methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 15:24:38'!
selectedClass
	"Answer the class that is currently selected. Answer nil if no selection exists."
	"Nota Bene: replaces method in base system"
	| name |
	(name _ self selectedClassName) ifNil: [^ nil].
	^ self environment at: name ifAbsent: nil! !

!Categorizer methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 14:00:28'!
classesAt: aCategoryName
	"Nota Bene: I replace a base system method."
	
	| environment |
	environment _ Smalltalk at: ((aCategoryName asIdentifier: true) asSymbol) ifAbsent: [ nil ].
	^environment 
		ifNil: [(self listAtCategoryNamed: aCategoryName) 
							collect: [:aClassName | Smalltalk classNamed: aClassName] 
		]
		ifNotNil: [ environment values ]  
	
		! !

!Categorizer methodsFor: '*system-environments' stamp: 'KenD 6/9/2020 13:52:25'!
listAtCategoryNamed: categoryName
	"Answer the array of elements associated with the name, categoryName."
	"Nota Bene: I replace a base system method"
	| environment  |
	environment  _ Smalltalk at: ((categoryName asIdentifier: true) asSymbol) ifAbsent: [nil].
	environment 
		ifNotNil: [ ^ environment keys ]
		ifNil: [| i | 
			i _ categoryArray indexOf: categoryName ifAbsent: [^Array new].
			^ self listAtCategoryNumber: i 
		]! !
