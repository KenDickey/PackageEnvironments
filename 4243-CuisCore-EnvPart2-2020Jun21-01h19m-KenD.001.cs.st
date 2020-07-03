'From Cuis 5.0 [latest update: #4242] on 21 June 2020 at 1:19:33 am'!

!MethodReference methodsFor: 'queries' stamp: 'KenD 6/21/2020 01:19:52'!
environment

	^categoryName 
		ifNil: [ Smalltalk ]
		ifNotNil:  [ Smalltalk environmentFromSystemCategory: categoryName ]! !


!CodeWindow methodsFor: 'updating' stamp: 'KenD 7/3/2020 10:21:46'!
updateListsAndCode
	"All code windows receive this message on any code change in the system"
	self canDiscardEdits ifTrue: [
		self allMorphsDo: [ :m | (m is: #PluggableListMorph) ifTrue: [ m verifyContents ]].
		model ifNotNil: [ model updateIfNeeded ]]! !
