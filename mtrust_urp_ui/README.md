# URP UI
Contains a collection of ui elements for the Universal Reader Platform (URP).


## Widgets

ReaderConnector

* Can be used by an application to establish a connection with any of the available readers.
* The widget displays a carousel of available readers, and the user can select a reader to connect to.
* If the mode is  PreferLastUsed, the widget will automatically connect to the last used reader, if its the only reader available, otherwise it will display the carousel with the last used reader as the first item.
* If the mode is Ephemeral, the widget will not remember the last used reader, and will always display the carousel of available readers.
* If the mode is Pairing, the widget will force the user to select a reader from the carousel, it will remember the last used reader and always connect to it in the future.

