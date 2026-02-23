# manual_E2EE

manual_E2EE is a free, open-source, third-party application that enables manual end-to-end encryption (E2EE) for desktop messaging platforms that do not natively provide encryption.

This software allows users to encrypt and decrypt messages locally using RSA public-key cryptography before transmitting them over any communication platform.

License

This project is licensed under the MIT License — see the LICENSE file for details.

This software is provided “as is”, without warranty of any kind, express or implied, including but not limited to merchantability, fitness for a particular purpose, and non-infringement. Use at your own risk.

FAQ

Q: What does this do?
A: It encrypts and decrypts messages with RSA end to end encryption to prevent unintended recipients from accessing your messages

Q: How do I use this?
A:
    1: You and your intended recipients download this software
    2: You and your intended recipients click [ Download my Public Key ]
    3: You and your intended recipients share the resulting public key files with each other through any method
    4: Compose a message
    5: Load your intended recipient's key by clicking [ Load Recipient's Key ]
    6: Click [ Copy Encrypted Message ]
    7: Send the copied encrypted message to your intended recipient on your platform of choice
    8: Your recipient will copy the encrypted message and click [ Decrypt Copied Message ] to gain access to the raw text of the original message you composed 

Q: Why does this exist?
A: Some people want to use messaging platforms that do not offer messaging privacy but still want messaging privacy, this allows you to force E2EE on any messaging platform (even smoke signals if you want)

Q: Will this stop large institutions from surveiling my messages?
A: Short answer; no. A sufficiently well funded institution can break RSA encryption. However RSA encryption is computationally expensive to break. This software reduces the likelihood of casual interception and automated scanning, but it does not guarantee protection against targeted surveillance, endpoint compromise, malware, physical device access, or implementation vulnerabilities.

Q: If I share my key over a messaging platform, can't the platofmr just take that key to intercept my messages?
A: No. The public key is mathematically incapable of decrypting messages. It can only encrypt messages intended for the holder of the corresponding private key. Your private key is stored locally on your device and is used to decrypt messages sent to you. Anyone who gains access to your private key can decrypt messages intended for you. Protect your private key.

Q: I think my private key is compromised, what do I do?
A:
    1: Delete the file named e2ee_private_key.pem in this software's directory
    2: Restart the software
    3: Share your new public key with your contacts
    4: Inform your contacts that previous messages encrypted with your old key should be considered compromised

Q: Why is this free? What's the catch?
A: No catch. This software was created voluntarily and is released as open source so that anyone can inspect, audit, and verify its behavior. You are encouraged to review the source code yourself or have it audited by someone you trust.

Q: This is inconvienient as hell
A: That's not a question, and yes, I agree, long term I plan to add the capacity for manual_E2EE to directly interact with your specified messaging platforms to make things smoother
