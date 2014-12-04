
## CRParse ##

These classes are meant to make interacting with Parse as generic as possible. However, one must have a good understanding of the Objective-C runtime environment and be comfortable with generating JSONS in cloud code that will fit your local schematic as well as KVO and how to handle the different results from incorrect keys and values.  The one thing I have yet to inplement is n:n relationships as I had no need for them, however it won't be hard to add them in.

### Clas Hierachry ###

The main work-horse of the model is the CRDataService, this takes in the NSDictionary (or NSArray of NSDictionaries) of key-value pairs and stores them locally.

The CRCoreDataStore is taken from: [here](http://robots.thoughtbot.com/core-data) and it goes with a rather thorough description (I have used the second setup)

There exists a CRManagedObject which all the other managed objects inherit from, and this guides the setting of values as well (and importantly) the 1:1 relationships between objects.

Each ManagedObject (MO) must have an id with which will associated with the objectId from parse.

There are a two categories one on the NSArray and one on the NSMutableDictionary (although the NSArray one uses the new method on the NSDictionary) which strips the properties and values off of the ManagedObjects and the ParseObject (not a subclass of parse) and converts it into values and keys to be saved either locally or on Parse.

The JSON (and by extension therefore as a result of deserializing on Parse's behalf) must be similar to:

			{
  				id : kBZlL299JT,
  				class : CRExample
  				toManyRelation: [
                    {
            
                    },
                    {


                    }
                ],
  				toOneRelation : {

                  }
				classSpecificProperty: true

				}

* the name of the local managed object class, this is used to fetch the local managed object or create a new one and is stripped from the keys. Make this the same on parse and locally to make things super easy.
* The to many relation must also be an array of jsons containing the class name and the id of the object on parse
* The 1:1 is the same and needs the id and class

In each of these JSONs insert what ever properties you want, but make sure they match the local storage properties on that class otherwise they will not save

It's recurssive so aslong as there are jsons and arrays it will keep dropping down and filling out the relationships of the MOs

Because there was a need for having multiple relationships to the same class from a single class, the relationship properties were defined as example1Id and example2Id both pointing to the same class. This discretion is handled in the:

    - (void) setValue:(id)value forUndefinedKey:(NSString *)key

whereby the key is points to the managed object with an id of value and local storage specific relationships can be filtered out. As in mine. 

As I was storing photos which came from photoUrls I also have a CRPhotoService which handles that approriately and stored the photo url, the photo data and the statusCode returned from the NSURLConnection.

All the methods are called from which an NSOperationQueue so as not to lock up the UI. That is, except for the save object to parse which is called from the main queue. 

In a nutshell:

		The CRBackgroundFetchHandler stores the NSOperationQueue and adds a subclass of NSOperation to the queue called CRBackgroundFetchOperation. This called the CRParseService which returns the aforementioned JSON using PFCloud. 
		
		The results of which are transferred over the CRDataService (one is a single json object with many different relationships and types of relationships) and the other is an array of objects which map to different ids within the original object. I took them out to prevent repetition of data from the server.
		
		The CRDataService uses dictionary that the cloud function spits out and builds the managed object around it searching for the id (if no id is provided this means that it is trying to save a new object in the saveObjectToParse and the method by which I implement that is stored there)
		
		The CRManagedObject then builds a lot of the relationships aswell as handles the photos for that object.
		
If you have any questions do please get in touch!
