
### What this component does

attaches a signin alias to the remote account
attaches a password policy to the remote account
creates a bucket in the central account to store state for the remote account
creates a CMK in the central account to encrypt that state
delegates via resource policies access to those resources to the remote account
creates a limited techops role in the remote account to be used for day to day admin
attaches policies to that techops account to
	* grant access to central account bucket and key
	* limit ability to create users or modify techops policy or attach admin policy to any role
creates a group in the central account with permissions to assume that remote account