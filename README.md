Early experiment with lightweight Environment / Namespace usage in Packages.

I.e. Package based environments.

Status: Code Sketch [pre-alpha; feaure incomplete; expect breakage]


Early thoughts:

Goal: Multiple Classes with same name coexist in different package environments.

Weak Goal: Cuis users won't notice until they need it.

- Current name lookup is local -> Smalltalk
- New name lookup is local -> PackageEnv -> Smalltalk

Selectors are polymorphic (method names don't care).

Instanced know their Class.

Packages which #require: other packages = packages #use: other packages.

=> Packages have an "Environment" dictionary of Class-name -> Class.

- Packages which #use: another package import that Package's Environment
but for the names defined locally in the using package 
  ["Copy-down with override" semantics]

So, any lookup is just in one leaf dictionary, no nesting.

Tools maintain relations (e.g. delete Class in #used: => delete Class binding in using Packages).

Note that Packages can be versioned: I.e. A Class in version N can differ from a Class in version N+1; instances are of distinct classes.  Same mechanics as PackageA vs PackageB with duplicate Class names.  This is probably a version fork" operation as distinct from typical usage as now.


[What tools?  How2 make visible w/o clutter?]

What is the simplest thing that will work?

- ```Environment fromFeature: 'FeatureName'.```
- Extend a current environment to include a cluster/cohort of Features.

TRY IT OUT

In your Cuis-Smalltalk directory:
```git clone https://github.com/KenDickey/PackageEnvironments```

Currently, only able to convert a pre-loaded Feature into an Environment.

````smalltalk
Feature require: 'System-Environments'.
Feature require: 'Morphic-Games-Solitaire'.
Environment fromFeature: 'Morphic-Games-Solitaire'.  "Answer YES to popup"
(MorphicGamesSolitaire @ #FreeCell) newGameWitthScale: 0.8.
"Or World Menu -> New Morph.. -> Layouts -> FreeCell"
HierarchyBrowserWindow onClass: (MorphicGamesSolitaire @ #FreeCell) selector: nil.
Smalltalk at: #Klondike put: (MorphicGamesSolitaire @ #Klondike).
Klondike newGame.
````

One can open a Class or Hierarchy Browser, add a 'self halt' breakpoint, trigger it.  Debugger seems OK.

Easy mechanics.  Look at Environment>>fromCodePackage:

Most work is tools.

I have not even looked at refactorings yet, nor multiple package 'cohorts'.

