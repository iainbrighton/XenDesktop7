
## XD7StoreFrontWebReceiverCommunication

Set the WebReceiver communication settings

### Syntax

```
XD7StoreFrontWebReceiverCommunication [string]
{
    StoreName = [String]
    [ Attempts = [UInt32] ]
    [ Timeout = [String] ]
    [ Loopback = [String] { On | Off | OnUsingHttp } ]
    [ LoopbackPortUsingHttp = [UInt32] ]
    [ ProxyEnabled = [Boolean] ]
    [ ProxyPort = [UInt32] ]
    [ ProxyProcessName = [String] ]
}
```

### Properties

* **StoreName**: StoreFront store name.
* **Attempts**: How many attempts WebReceiver should make to contact StoreFront before it gives up.
* **Timeout**: Timeout value for communicating with StoreFront.
* **Loopback**: Whether to use the loopback address for communications with the store service, rather than the actual StoreFront server URL.
* **LoopbackPortUsingHttp**: When loopback is set to OnUsingHttp, the port number to use for loopback communications.
* **ProxyEnabled**: Is the communications proxy enabled.
* **ProxyPort**: The port to use for the communications proxy.
* **ProxyProcessName**: The name of the process acting as proxy.

### Configuration

```
Configuration XD7Example {
    Import-DscResource -ModuleName XenDesktop7
    XD7StoreFrontWebReceiverCommunication XD7StoreFrontWebReceiverCommunicationExample {
        StoreName = 'mock'
        Loopback = 'OnUsingHttp'
    }
}
```
