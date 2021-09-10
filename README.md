
# ActivityMonitor
An easy way to detect user inactivity with very simple usage API.


## Why?

There are many ways to observe if user is not interact with our app for certain amount of time. Some suggest to subclass **UIApplication** and override the **sendAction** method and apply logic from there. Other suggest to subclass **UIWindow** which is also correct. However, what if we don't want to subclass?

## How it works

Here's how it work:
1. Fire our timer (For this, I used DispatchSource. You can use anything you prefer)
2. Observe touches in hittest method of **UIWindow** and apply logic there
3. That's pretty much it!

## How to use
```
IdleActivityMonitor.onTimeout { 
	// do something here
}
IdleActivityMonitor.startMonitoring()
```

## Where to put it?
It depends on your usage. You can put it anywhere you want to observe the inactivity.
For most use cases, this should be in **AppDelegate** didFinishLaunchingWithOptions.

## Now what?
Well, that's pretty much it. Now we could find a way to detect if user not touch screen for certain amount of time without subclass **UIApplication** or **UIWindow**.
