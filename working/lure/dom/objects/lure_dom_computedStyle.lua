lure.dom.computedStyleObj = {}

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function lure.dom.createComputedStyleObj(pAttachNode)
	local self = {}
				
	--===================================================================
	-- OBJECT METATABLE                                                 =
	--===================================================================
	local self_mt = {}	
	---------------------------------------------------------------------
	self_mt.__tostring = function(t)
		return "[object]:CssRuleStyleObject"
	end
	---------------------------------------------------------------------
	self_mt.__index = function(t,k)
		--print(tostring(t) .. "[" .. tostring(k) ..  "]")
		if k == "styleRefStore" or
		   k == "specificity" or
		   k == "parent" then			
			return rawget(t, k)
		else			
			return lure.dom.computedStyleObj.getProperty(self, k)		
		end		
	end
	---------------------------------------------------------------------
	self_mt.__newindex = function(t,k,v)
		return lure.dom.computedStyleObj.setProperty(self,k,v)		
	end
	---------------------------------------------------------------------
			
	--===================================================================
	-- PROPERTIES                                                       =
	--===================================================================
	self.parent 		= pAttachNode
	---------------------------------------------------------------------
	self.specificity 	= {0, 0, 0, 0}
	---------------------------------------------------------------------
	self.styleRefStore 	= {}
	---------------------------------------------------------------------
	
	--====================================================================
	-- METHODS	                                                         =	
	--====================================================================
	self.getStyleText = function()
		local cssText = ""
		for a=1, table.getn(self.styleRefStore) do
			cssText = cssText .. self.styleRefStore[a].key .. ":" .. self.styleRefStore[a].value .. ";"
		end
		return cssText		
	end
	---------------------------------------------------------------------
	
	setmetatable(self, self_mt)
	return self
end

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function lure.dom.computedStyleObj.getProperty(pObjRef, pPropertyName)		
	local self = pObjRef
	local isValidPropertyName	= false	
	local cssDef				= nil
	local returnValue			= ""
	
	for k1, v1 in pairs(lure.dom.css_property_definitions) do		
		if pPropertyName == lure.dom.css_property_definitions[k1].css_to_style_equiv then			
			cssDef = lure.dom.css_property_definitions[k1]
			isValidPropertyName = true			
		end
	end
	
	if isValidPropertyName then		
		for a=1, table.getn(self.styleRefStore) do
			if self.styleRefStore[a].key == pPropertyName then
				return self.styleRefStore[a].value
			end
		end
		return cssDef.initial
	else
		lure.throw(1, "Cannot get unsupported CSS key '".. pPropertyName .."'")
	end	
end

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function lure.dom.computedStyleObj.setProperty(pObjRef, pPropertyName, pPropertyValue)
	local self 					= pObjRef
	local isValidPropertyName	= false
	local isValidPropertyValue	= false
	local cssDef				= nil
	
	for k1, v1 in pairs(lure.dom.css_property_definitions) do		
		if pPropertyName == lure.dom.css_property_definitions[k1].css_to_style_equiv then			
			cssDef = lure.dom.css_property_definitions[k1]
			isValidPropertyName = true			
		end
	end
	
	if isValidPropertyName == true then
		if cssDef.validateValue(pPropertyValue) == true then
			isValidPropertyValue 	= true
			newStyleRef 			= table.insert(self.styleRefStore, 
			{
				key		=	lure.trim(pPropertyName),
				value	=	lure.trim(pPropertyValue)
			})
		else
			lure.throw(1, "CSS Definition value '".. pPropertyName .. ":" .. pPropertyValue ..";' is malformed or unsupported. Declaration will be dropped")
		end
	else
		lure.throw(1, "Unsupported CSS key '"..pPropertyName.."' Declaration will be dropped.")
	end		
end

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::