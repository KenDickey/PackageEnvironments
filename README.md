## A Package can be used as a Feature or an Environment
============

Early experiment with lightweight Environment / Namespace usage in Packages.

I.e. Package based environments.

Early thoughts:

Goal: Multiple Classes with same name coexist in different package environments.

Weak Goal: Cuis users won't notice until they need it.

I would like ```Environment fromFeature: 'MyFeature.``` to be like ```Feature require: 'MyFeature'.``` but the result is an environment.

## TRY IT OUT
=============
Status: Code Sketch [pre-alpha; feaure incomplete; expect breakage. FILE OUT CHANGES ST YOUR OWN RISK !!

In your Cuis-Smalltalk directory:
```git clone https://github.com/KenDickey/PackageEnvironments```

Currently, only able to convert a pre-loaded Feature into an Environment.

````smalltalk
ChangeSet fileIn: (DirectoryEntry smalltalkImageDirectory parent // 'PackageEnvironments/4242-CuisCore-PreEnvironment-2020Jun28-09h03m-KenD.001.cs.st').
ChangeSet fileIn: (DirectoryEntry smalltalkImageDirectory parent // 'PackageEnvironments/4243-CuisCore-EnvPart2-2020Jun21-01h19m-KenD.001.cs.st').
ChangeSet fileIn: (DirectoryEntry smalltalkImageDirectory parent // 'PackageEnvironments/4244-CuisCore-KenDickey-2020Jun21-02h13m-KenD.002.cs.st').

Feature require: 'System-Environments'.
Feature require: 'Morphic-Games-Solitaire'.

"CardMorph is a Class in Morphic-Games-Solitaire"
CardMorph name.

"Convert 'Morphic-Games-Solitaire' from a FEATURE into an Environment"
Environment fromFeature: 'Morphic-Games-Solitaire'.  "Answer YES to popup"

"Classes Klondike and FreeCell are exported from Environment"
FreeCell newGameWithScale: 0.8. 
"Or World Menu -> New Morph.. -> Layouts -> FreeCell"

"Class #CardMorph is no longer visible in Smalltalk SystemDictionary
 but can be accessed through its Enviromment, #MorphicGamesSolitaire"
'Morphic-Games-Solitaire.pck.st' asEnvironmentName.
HierarchyBrowserWindow onClass: (MorphicGamesSolitaire @ #CardMorph)
		       selector: #aboutToBeGrabbedBy: .
````

One can open a Class or Hierarchy Browser, add a 'self halt' breakpoint, trigger it.  Debugger seems OK.  ChangeSets work with added methods.

```Environment fromFeature: 'MyFeature'``` adds #required Environments.


## Notes
========

- Current name lookup is local -> Smalltalk
- New name lookup is local -> PackageEnv -> Smalltalk

Selectors are polymorphic (method names don't care).

Instanced know their Class.  Classes know their CodePackage.

Packages which #require: other packages = packages #use: other packages.

=> Packages have an "Environment" dictionary of Class-name -> Class.

- Packages which #require: another package import that Package's Environment

Currently, I am using (deprecated) sharedPool, which could be renamed to sharedEnvironment.


[What tools?  How2 make visible w/o clutter?]

What is the simplest thing that will work?

- ```Environment fromFeature: 'FeatureName'.```
- Extend a current environment to include a cluster/cohort of Features.

Easy mechanics.  Look at Environment>>fromCodePackage:

Most work is teaching tools to look at Environments rather than just Smalltalk.  Note ```SystemDictionary>>environmentFromSystemCategory:```

##The Story So Far
==========
- A Package can be used as a Feature or an Environment.
- Can use ```Environment class>>fromFeature: 'FeatureName'``` to convert a 'FeatureName' (category) to an Environment.
- When created, Environments check #required: Features, and #use their Environments if they have them.
- (Class) Browser, Hierarchy Browser seem OK, but for syntax hilighting.
- ChangeSorter/ChangeSets seem OK.
- The standard way to export a public Class from Environment to Smalltalk is for that Class to define a Class Method #environmentsExportMe which returns true.


##Next Steps
==========
- Package Save exports Class Def with poolDictionaries; should not see them.
- Need to get UI to denote Classes named in Environments but unknown in/to Smalltalk.
- Much testing

I have not even looked at refactorings yet, nor multiple package 'cohorts'.

[Note that Packages can be versioned: I.e. A Class in version N can differ from a Class in version N+1; instances are of distinct classes.  Same mechanics as PackageA vs PackageB with duplicate Class names.  This is probably a "version fork" operation as distinct from typical usage as now.]

