--------------------------------------------------
--------------------------------------------------
-- Import tasks from Things to OmniFocus
--------------------------------------------------
--------------------------------------------------
--
-- Script taken from: http://forums.omnigroup.com/showthread.php?t=14846&page=2
--

-- Added: creation date, due date, start date functionality

tell application "Things"
	
	-- Loop through ToDos	in Things
	repeat with aToDo in to dos of list "Next"
		
		-- Get title and notes of Things task
		set theTitle to name of aToDo
		set theNote to notes of aToDo
		set theCreationDate to creation date of aToDo
		set theDueDate to due date of aToDo
		set theStartDate to activation date of aToDo
		
		-- get dates
		if (creation date of aToDo) is not missing value then
			set theCreationDate to creation date of aToDo
		else
			set theCreationDate to today
		end if
		
		if (due date of aToDo) is not missing value then
			set theDueDate to due date of aToDo
		end if
		
		if (activation date of aToDo) is not missing value then
			set theStartDate to activation date of aToDo
		end if
		
		-- Get project name
		if (project of aToDo) is not missing value then
			set theProjectName to (name of project of aToDo)
		else
			set theProjectName to "NoProjInThings"
		end if
		
		-- Get Contexts from tags
		-- get all tags from one ToDo item...
		set allTagNames to {}
		copy (name of tags of aToDo) to allTagNames
		-- ...and from the project...
		if (project of aToDo) is not missing value then
			copy (name of tags of project of aToDo) to the end of allTagNames
		end if
		-- ...now extract contexts from tags
		copy my FindContextName(allTagNames) to theContextName
		
		-- Create a new task in OmniFocus
		tell application "OmniFocus"
			
			tell default document
				
				-- Set (or create new) task context
				if context theContextName exists then
					set theContext to context theContextName
				else
					set theContext to make new context with properties {name:theContextName}
				end if
				
				-- Set (or create new) project
				if project theProjectName exists then
					set theProject to project theProjectName
				else
					set theProject to make new project with properties {name:theProjectName}
				end if
				
				-- Create new task
				tell theProject
					set newTask to make new task with properties {name:theTitle, note:theNote, context:theContext, creation date:theCreationDate}
					
					if (theStartDate is not missing value) then set the start date of newTask to theStartDate
					
					if (theDueDate is not missing value) then set the due date of newTask to theDueDate
					
					
				end tell
				
			end tell -- document
		end tell -- OF application
	end repeat -- Main loop
end tell -- Things application


--------------------------------------------------
--------------------------------------------------
-- Get context from array of Things tags
--------------------------------------------------
--------------------------------------------------
on FindContextName(tagNames)
	-- Example usage
	--FindContextName("@Mac", "1/2hr", "High") -- FYI, my tags are context, duration and priority
	
	repeat with aTagName in tagNames
		if aTagName starts with "@" then
			return aTagName
		end if
	end repeat
	return ""
	
end FindContextName -- End FindContextName


--------------------------------------------------
--------------------------------------------------
-- Remove the CRs from a string,
-- not used in this script,
-- carry over from prior implementation
--------------------------------------------------
--------------------------------------------------
on ReplaceText(find, replace, subject)
	-- Example usage
	-- ReplaceText("Windows", "the Mac OS", "I love Windows and I will always love Windows and I have always loved Windows.")
	
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set subject to text items of subject
	
	set text item delimiters of AppleScript to replace
	set subject to "" & subject
	set text item delimiters of AppleScript to prevTIDs
	
	return subject
	
end ReplaceText -- End replaceText()