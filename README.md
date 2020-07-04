## A Package can be used as a Feature or an Environment
============

Early experiment with lightweight Environment / Namespace usage in Packages.

I.e. Package based environments.

Early thoughts:

I would like ```Environment fromFeature: 'MyFeature.``` to be like ```Feature require: 'MyFeature'.``` but the result is an environment.

Goals: 
- Multiple Classes with same name coexist in different package environments
- Unburden Smalltalk SystemDictionary by reducing the number of helper/support class names

Weak Goals: 
- Cuis users won't notice until they need it
- Introduce fewest new concepts and mechanisms
- Work as expected with current tools

Gist:
- Environments are IdentityDictionaries of Classes with their Feature and Smalltalk name.
- ```'Morphic-Games-Solitaire.pck.st' asEnvironmentName.``` -> 'MorphicGamesSolitaire'
- ```Environment fromFeature: 'Morphic-Games-Solitaire'.```
- Class bindings are moved from Smalltalk into an Environment
- Class>>```bindingOf:``` looks in that class's sharedPool,
 so adding the Environment to each class removed from Smalltalk
 uses standard lookup semantics and caching.
- ```Klondike``` class implements method ```environmentsExportMe``` which answers ```true```.
- Classes internal to an Environment are known by ```MorphicGamesSolitaire @ #CardMorph``` or just ```MorphicGamesSolitaire CardMorph```
- A Package is just a Package.  Saving a Package works the same for an Environment as a Feature.

## TRY IT OUT
=============

STATUS: Code Sketch [pre-alpha; feaure incomplete; expect breakage]

In your Cuis-Smalltalk directory:
```git clone https://github.com/KenDickey/PackageEnvironments```

Currently, only able to convert a pre-loaded Feature into an Environment.

````smalltalk
ChangeSet fileIn: (DirectoryEntry smalltalkImageDirectory parent // 'PackageEnvironments/4242-CuisCore-PreEnvironment-2020Jul01-14h23m-KenD.001.cs.st').
ChangeSet fileIn: (DirectoryEntry smalltalkImageDirectory parent // 'PackageEnvironments/4243-CuisCore-EnvPart2-2020Jun21-01h19m-KenD.001.cs.st').
ChangeSet fileIn: (DirectoryEntry smalltalkImageDirectory parent // 'PackageEnvironments/4244-CuisCore-EnvPart3-2020Jul01-14h29m-KenD.001.cs.st').

Feature require: 'System-Environments'.
Feature require: 'Morphic-Games-Solitaire'.

"CardMorph is a Class in Morphic-Games-Solitaire"
CardMorph name.

"Convert 'Morphic-Games-Solitaire' from a FEATURE into an Environment"
Environment fromFeature: 'Morphic-Games-Solitaire'.  "Answer YES to popup"

"Classes Klondike and FreeCell are exported from Environment"
FreeCell newGame. 
"Or World Menu -> New Morph.. -> Layouts -> FreeCell"

"Class #CardMorph is no longer visible in Smalltalk SystemDictionary
 but can be accessed through its Enviromment, #MorphicGamesSolitaire"
'Morphic-Games-Solitaire.pck.st' asEnvironmentName.
MorphicGamesSolitaire @ #CardMorph. "Same as:  MorphicGamesSolitaire CardMorph"
HierarchyBrowserWindow onClass: (MorphicGamesSolitaire CardMorph)
		       selector: #aboutToBeGrabbedBy: .

"Environments may be nested"
Feature require: 'Construction'.
Environment fromFeature: 'Game'. "required by Construction"
Environment fromFeature: 'Construction'.
"#Construction Environment is NOT Class #Construction but same name"
(Construction Construction) start. "Start the Construction Game"
Construction start. "Cute doesNotUnderstand hack to avoid name clash"
"Inspect a Class, eg, Construction Construction, and
  note both Construction and Game enOAvironments in sharedPools
  => bindingOf: finds required Classes"

````

One can open a Class or Hierarchy Browser, add a 'self halt' breakpoint, trigger it.  Debugger seems OK.  ChangeSets work with added methods.

```Environment fromFeature: 'MyFeature'``` adds #required Environments.


## Notes
========

Selectors are polymorphic (method names don't care).

Instanced know their Class.  Classes know their CodePackage.

Packages which #require: other packages = packages #use: other packages.

=> Packages can have an "Environment" dictionary of Class-name -> Class.

- Packages which #require: another package import that Package's Environment (if any)

Currently, I am using (deprecated) sharedPool, which could be renamed to sharedEnvironments.


[What tools?  How2 make visible w/o clutter?]

What is the simplest thing that will work?

- ```Environment fromFeature: 'FeatureName'.```
- Extend a current environment to include a cluster/cohort of Features.

Easy mechanics.  Look at ```Environment>>fromCodePackage:```

Most work is teaching tools to look at Environments rather than just Smalltalk.  Note ```SystemDictionary>>environmentFromSystemCategory:```

##The Story So Far
==========
- A Package can be used as a Feature or an Environment.
- Can use ```Environment class>>fromFeature: 'FeatureName'``` to convert a 'FeatureName' (category) to an Environment.
- When created, Environments check #required: Features, and #use their Environments if they have them.
- (Class) Browser, Hierarchy Browser seem OK, but for syntax hilighting.
- ChangeSorter/ChangeSets seem OK.
- The standard way to export a public Class from Environment to Smalltalk is for that Class to define a Class Method ```environmentsExportMe``` which returns true.
- Class & Hierarchy Browsers, Package Browser, ChangeSorter, Debugger seem to work OK.
- Package Save/FileOut working (same for Feature or Environment).
- ChangeSets seem OK.
- Packages which create multiple Categories seem OK.
- Find Class works in (System) Browser.


##Next Steps
==========
- Need to be able to add new Classes to an Environment (Create in Browser).
- Need to get UI to denote Classes named in Environments but unknown in/to Smalltalk. [Now RED. Make GREEN?]
- Take a Feature which has not been #require:'d and compile into an Environment.
- Much testing

I have not even looked at refactorings yet, nor multiple package 'cohorts'.

[Note that Packages can be versioned: I.e. A Class in version N can differ from a Class in version N+1; instances are of distinct classes.  Same mechanics as PackageA vs PackageB with duplicate Class names.  This is probably a "version fork" operation as distinct from typical usage as now.]

##Issues
- Setup for compilation is way too complex and not intuitive. [Browser>>defineClass:notifying: -> Compiler class>>evaluate:notifying:logged: -> many onion skin layers before parsing a token].

