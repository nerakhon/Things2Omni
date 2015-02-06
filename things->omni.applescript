--------------------------------------------------
--------------------------------------------------
-- Import tasks from Things to OmniFocus
--------------------------------------------------
--------------------------------------------------
--
-- Script originally from: http://forums.omnigroup.com/showthread.php?t=14846&page=2
--

-- Added: creation date, due date, start date functionality
-- Added: area of responsibilities 

tell application "Things"
	
	-- Loop through ToDos	in Things
	repeat with aToDo in to dos of list "Next"
		
		-- Get title and notes of Things task
		set theTitle to name of aToDo
		set theNote to notes of aToDo
		set theCreationDate to creation date of aToDo
		set theDueDate to due date of aToDo
		set theStartDate to activation date of aToDo
		
		get properties of aToDo
		
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
			set theProjectName to "Misc"
		end if
		
		-- get areas
		if (area of aToDo) is not missing value then
			set theAreaName to (name of area of aToDo)
		else if (area of project of aToDo) is not missing value then
			set theAreaName to (name of area of project of aToDo)
		else
			set theAreaName to "MissingArea"
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
				
				-- Create an area for projects and tasks
				
				if folder theAreaName exists then
					set theFolder to folder theAreaName
				else
					set theFolder to make new folder with properties {name:theAreaName}
				end if
				
				-- Set (or create new) project
				-- get properties of project theProjectName in folder theAreaName
				
				if project theProjectName in theFolder exists then
					set theProject to project theProjectName in theFolder
				else
					tell theFolder
						set theProject to make new project with properties {name:theProjectName}
					end tell
				end if
				
				-- Create new task
				tell theProject
					set newTask to make new task with properties {name:theTitle, note:theNote, context:theContext, creation date:theCreationDate}
					
					if (theStartDate is not missing value) then set the defer date of newTask to theStartDate
					
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
