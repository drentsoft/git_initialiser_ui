extends Panel

onready var projectDir = $VBoxContainer/ProjectHBox/Path
onready var VCSPath = $VBoxContainer/VCSHBox/VCSPath
onready var placeholderInput = $VBoxContainer/PlaceholderHBox/PlaceholderNameEdit
onready var writePlaceholerContents = $VBoxContainer/PlaceholderHBox/writePlaceholderContents
onready var placeholderContent = $VBoxContainer/PlaceholderHBox/writePlaceholderContents/PlaceholderContentsPopup/PlaceholderContent
onready var logOutput = $VBoxContainer/LogOutput

var regex

func _ready():
	var runningPath = "Running from: %s" % OS.get_executable_path()
	print(runningPath)
	regex = RegEx.new()
	regex.compile("\\[(\\w+).*?\\].*?\\[/\\1\\]")
	#regex.compile("/\\[\\/?(?:b|i|u|s|left|center|right|quote|code|list|img|spoil|color).*?\\]")
	#regex.compile("/\\[\\/?[^\\]]*\\]")
	$VBoxContainer/VCSHBox/VCSPath.placeholder_text = $Initialiser.DEFAULT_VCS
	$VBoxContainer/LogOutput.bbcode_text = "[color=yellow]%s[/color]\n" % runningPath
	placeholderContent.text = $Initialiser.placeholder_content

func _on_PathBrowseBtn_pressed():
	$FileDialog.current_dir = projectDir.text
	$FileDialog.show()

func _on_PathBrowseBtn_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		OS.shell_open(str("file://",projectDir.text))

func _on_FileDialog_confirmed():
	projectDir.text = $FileDialog.current_dir

func _on_AddIgnorePathBtn_pressed():
	pass # Replace with function body.

func _on_CleanBtn_pressed():
	$CleanConfirmationDialog.popup()

func _on_CleanConfirmationDialog_confirmed():
	var colour := "green"
	if $Initialiser.cleanup == $Initialiser.Cleanup.FORCE_CLEAN:
		colour = "#FF9900"
	logOutput.bbcode_text += "\n[color=%s]Cleaning project![/color]\n" % colour
	$Initialiser.check_for_child_directories(projectDir.text)

func _on_InitBtn_pressed():
	print("Initialisation requested...")
	if projectDir.text.nocasecmp_to(OS.get_executable_path()) == 0 or projectDir.text.nocasecmp_to("") == 0:
		projectDir.text = OS.get_executable_path()
		print("Using current folder. Are you sure?")
		$OwnDirConfirmationDialog.popup()
	else:
		print("Initialising...")
		if placeholderInput.text.length() > 0:
			$Initialiser.placeholder_filename = placeholderInput.text
		$Initialiser.write_placeholder_text = writePlaceholerContents.pressed
		var placeholder_output : String
		if $Initialiser.write_placeholder_text:
			placeholder_output = "[color=green]Will write content to placeholder files.[/color]"
		else:
			placeholder_output = "[color=red]Will write empty placeholder files.[/color]"
		logOutput.bbcode_text += "%s\n" % placeholder_output
		$Initialiser.placeholder_content = placeholderContent.text
		logOutput.bbcode_text += "\n Initialising repository...\n"
		$Initialiser.check_for_child_directories(projectDir.text)

func _on_Initialiser_output(msg: String):
	var res = regex.search(msg)
	if res:
		print(res.get_string())
	print(msg)
	$VBoxContainer/LogOutput.bbcode_text += msg + "\n"

func _on_VCSPath_text_changed(new_text):
	$Initialiser.vcs_dir = VCSPath.text
	if VCSPath.text.length() == 0:
		$Initialiser.vcs_dir = $Initialiser.DEFAULT_VCS

func _on_HelpBtn_pressed():
	$HelpDialog.popup()

func _on_CleanOptionsBtn_item_selected(ID):
	$VBoxContainer/CleanHBox/CleanBtn.disabled = (ID == $Initialiser.Cleanup.NO_CLEAN)
	$VBoxContainer/HBoxContainer3/InitBtn.disabled = (ID > $Initialiser.Cleanup.NO_CLEAN)
	$Initialiser.cleanup = ID

func _on_writePlaceholderContents_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		$VBoxContainer/PlaceholderHBox/writePlaceholderContents/PlaceholderContentsPopup.popup_centered()

func _on_ClearOutputBtn_pressed():
	logOutput.bbcode_text = ""
