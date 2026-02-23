extends Control

@onready var full_screen_button: Button = $PanelContainer/VBoxContainer/Title_Bar/aux_buttons/FullScreen
@onready var tab_container: TabContainer = $PanelContainer/VBoxContainer/HBoxContainer/TabContainer
@onready var outgoing_message: TextEdit = $PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Outgoing_Message
@onready var incoming_message: TextEdit = $PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Incoming_Message
@onready var copy_encoded_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/Info/CopyEncoded

const KEY_FILE_PATH: String = "user://e2ee_private_key.pem"

var crypto: Crypto = Crypto.new()
var keypair: CryptoKey
var recipient_key: CryptoKey = null

func _ready() -> void:
	generate_keypair()
	
	var tab_bar: TabBar = tab_container.get_tab_bar()
	tab_bar.set_tab_title(0, "Outgoing Message")
	tab_bar.set_tab_title(1, "Incoming Message")
	tab_bar.current_tab = 0
	copy_encoded_button.disabled = true

func generate_keypair() -> void:
	keypair = CryptoKey.new()
	
	if FileAccess.file_exists(KEY_FILE_PATH):
		print("Key file found")
		
		var file = FileAccess.open(KEY_FILE_PATH, FileAccess.READ)
		if file == null:
			push_error("Failed to open key file")
			return
		
		var pem_str = file.get_as_text()
		file.close()
		
		var err = keypair.load_from_string(pem_str)
		if err != OK:
			push_error("Failed to load keypair from PEM")
			return
		
		print("Keypair loaded successfully")
		
	else:
		print("No key found. Generating new keypair")
		keypair = crypto.generate_rsa(2048)
		
		var pem_str = keypair.save_to_string(false) # false = include private key
		var file = FileAccess.open(KEY_FILE_PATH, FileAccess.WRITE)
		file.store_string(pem_str)
		file.close()
		
		print("New keypair generated and saved")

func _on_copy_encrypted_message_pressed() -> void:
	# Get message text
	var message: String = outgoing_message.text
	if message.strip_edges() == "":
		push_error("No message to encrypt")
		return
	
	# Make sure recipient key is loaded
	if recipient_key == null:
		push_error("Recipient public key is not loaded")
		return
	
	# Convert message to bytes
	var message_bytes: PackedByteArray = message.to_utf8_buffer()
	
	# Encrypt using Crypto.rsa_encrypt
	var encrypted_bytes: PackedByteArray = crypto.encrypt(recipient_key, message_bytes)
	
	if encrypted_bytes.is_empty():
		push_error("Encryption failed")
		return
	
	# Convert to Base64 for safe clipboard copy
	var encrypted_base64: String = Marshalls.raw_to_base64(encrypted_bytes)
	DisplayServer.clipboard_set(encrypted_base64)
	
	print("Encrypted message copied to clipboard successfully")

func _on_get_public_key_pressed() -> void:
	if keypair == null:
		push_error("Keypair not initialized")
		return
	
	# Create dialog
	var dialog: FileDialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.title = "Save My Public Key"
	dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	dialog.current_file = "PEM_Public_Key.pem"
	dialog.add_filter("*.pem ; PEM Public Key")
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	
	# Wait for user selection
	var selected_path: String = await dialog.file_selected
	dialog.queue_free()
	
	# If user cancelled, selected_path will be empty
	if selected_path.is_empty():
		print("User cancelled save dialog")
		return
	
	# Ensure .pem extension
	if selected_path.get_extension() != "pem":
		selected_path += ".pem"
	
	var pem_bytes: PackedByteArray = keypair.save_to_string(true).to_utf8_buffer()
	var file: FileAccess = FileAccess.open(selected_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to create public key file")
		return
	
	file.store_buffer(pem_bytes)
	file.close()
	
#	file.store_string(keypair.save_to_string(true))
#	file.close()
	
	print("Public key saved to: ", selected_path)

func _on_load_recipient_key_pressed() -> void:
	# Create dialog
	var dialog: FileDialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.title = "Select Recipient Public Key"
	dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	dialog.add_filter("*.pem ; PEM Public Key")
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	
	copy_encoded_button.disabled = true
	
	# Wait for selection
	var selected_path: String = await dialog.file_selected
	dialog.queue_free()
	
	if selected_path.is_empty():
		print("User cancelled key selection")
		return
	
	# Open selected file
	var file: FileAccess = FileAccess.open(selected_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open selected key file")
		return
	
	var bytes: PackedByteArray = file.get_buffer(file.get_length())
	file.close()
	var pem_string: String = bytes.get_string_from_utf8().strip_edges()
	
#	var pem_string: String = file.get_as_text()
#	file.close()
	
	# Attempt to load key
	var loaded_key: CryptoKey = CryptoKey.new()
	var err = loaded_key.load_from_string(pem_string, true)
	if err != OK:
		push_error("Invalid PEM file or unsupported key format")
		return
	
	# Validate that it does NOT contain a private key
	if not loaded_key.is_public_only():
		push_error("Selected key contains a private key. Public key required")
		return
	
	recipient_key = loaded_key
	copy_encoded_button.disabled = false
	print("Recipient public key loaded successfully")

func _on_decode_copied_pressed() -> void:
	# Make sure the user's private key is loaded
	if keypair == null or keypair.is_public_only():
		push_error("User private key not loaded.")
		return
	
	# Read encrypted Base64 text from clipboard
	var clipboard_text: String = DisplayServer.clipboard_get()
	if clipboard_text.strip_edges() == "":
		push_error("Clipboard is empty.")
		return
	
	# Attempt to decode Base64
	var encrypted_bytes: PackedByteArray
	# Wrap in error handling in case the clipboard is not valid Base64
	# Marshalls.base64_decode will return an empty array on invalid Base64
	encrypted_bytes = Marshalls.base64_to_raw(clipboard_text)
	if encrypted_bytes.is_empty():
		push_error("Clipboard content is not valid Base64 or is empty.")
		return
	
	# Decrypt using user's private key
	var decrypted_bytes: PackedByteArray = crypto.decrypt(keypair, encrypted_bytes)
	if decrypted_bytes.is_empty():
		push_error("Decryption failed. Possibly wrong key or corrupted ciphertext.")
		return
	
	# Convert decrypted bytes to UTF-8 string
	var decrypted_message: String = decrypted_bytes.get_string_from_utf8()
	
	# Push to the incoming_message TextEdit
	incoming_message.text = decrypted_message
	print("Decrypted message loaded successfully.")
	tab_container.current_tab = 1
