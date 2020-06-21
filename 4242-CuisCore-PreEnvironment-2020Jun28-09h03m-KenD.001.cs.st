'From Cuis 5.0 [latest update: #4241] on 28 June 2020 at 9:16:37 am'!
!classDefinition: #MethodReference category: #'Tools-Browser'!
Object subclass: #MethodReference
	instanceVariableNames: 'classSymbol classIsMeta methodSymbol stringVersion categoryName '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Browser'!

!MethodReference commentStamp: '<historical>' prior: 0!
I am used to keep track of a Method but without a direct pointer.

I need to be able to find the Method I represent, even if the Class holding that Method is in an Environment and not in the Smalltalk SystemDictionary.
!


!String methodsFor: 'converting' stamp: 'KenD 6/21/2020 02:00:37'!
asEnvironmentName
	"I am a system catargory name or a package name.
	Answer an adequate name for an environment, e.g. hyphens removed and first character uppercase."

	| name |
	name := (self withoutSuffix: '.pck.st') ifNil: [self] ifNotNil: [:trimmed | trimmed].
	^name asIdentifier: true! !


!SystemDictionary methodsFor: 'accessing' stamp: 'KenD 6/28/2020 09:13:37'!
environmentFromSystemCategory: categoryNameString
	"If  categoryNameString names an Environment, answer it, else answer self."
	
	self at: (categoryNameString asEnvironmentName asSymbol) 
		ifPresent: [:anObject| (anObject is: #Environment) ifTrue: [^ anObject]].
	^ self! !

!classDefinition: #MethodReference category: #'Tools-Browser'!
Object subclass: #MethodReference
	instanceVariableNames: 'classSymbol classIsMeta methodSymbol stringVersion categoryName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Browser'!
