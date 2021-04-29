--copyPose
struct objTm
(
	name,
	id,
	tm
)
struct posCopyTmList
(
	index,
	text,
	tmList
)
fn LogTm name tm = (
	print name
	print tm.row1
	print tm.row2
	print tm.row3
	print tm.row4
)
fn GeTnormalizeTm tm scale_value = (
	new_tm = matrix3 0
	new_tm.row1 = normalize tm.row1
	new_tm.row2 = normalize tm.row2
	new_tm.row3 = normalize tm.row3
	new_tm.row4 = tm.row4

	if scale_value != (Point3 1 1 1) then (
		new_tm.row1 = new_tm.row1 * scale_value.x
		new_tm.row2 = new_tm.row2 * scale_value.y
		new_tm.row3 = new_tm.row3 * scale_value.z
		new_tm.row4 = new_tm.row4
	)
	new_tm
)
fn mirror_fn arg_ndoe = (
	nodes = #()
	for obj in arg_ndoe do (
		new_bone = Point() 
		new_bone.parent = undefined
		new_tm = obj.transform
		
		new_tm = obj.transform * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])

		new_bone.transform = new_tm
		resetscale new_bone
		append nodes new_bone
	)
	nodes
)
fn GetFlipTm arg_node = (
	nodes = #()
	for obj in arg_node do (
		newobj = dummy()
		newobj.parent = undefined
		mirroredTm = matrix3 0
		mirrorTm = scaleMatrix [1,-1,1]
		flipTm = scaleMatrix [-1,-1,-1]
			--the Matrix to mirror on. Default is origin.
		pivotTm = matrix3 1
		finalTm = matrix3 1
		
		mirroredTm = (obj.transform * inverse pivotTm * mirrorTm) * pivotTm
		finalTm = flipTm * mirroredTm
		newobj.transform = finalTm
		append nodes newobj
	)
	nodes
)
fn SetMirrorNodes tm_list_arg olnyRot:false = (
	target_nodes = GetHierarchyNodes (selection as array)
	tm_list_nodes = #()
	isParent_tm = undefined
	point_nodes = #()
	for i = 1 to target_nodes.count do (
		obj = target_nodes[i]
		set_tm = tm_list_arg[i]
		if set_tm == undefined do contains
		local_tm =  set_tm.tm
		new_bone = Point() 
		new_bone.parent = undefined
		new_tm = local_tm
		if obj.parent != undefined do (
			if isParent_tm == undefined do isParent_tm = obj.parent.transform
			new_tm = local_tm * isParent_tm
		)
		mirror_tm = new_tm * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])
		new_bone.transform = mirror_tm
		resetscale new_bone
		fix_tm = prerotateZ  new_bone.transform 180
		new_bone.transform = fix_tm
		append point_nodes new_bone
		isParent_tm = copy new_tm
	)
	mirror_nodes = point_nodes
	animate on (
		for i = 1 to target_nodes.count do (
			mirror_node = mirror_nodes[i]
			obj = target_nodes[i] 
			if mirror_node == undefined do contains
			-- resetscale mirror_node
			new_tm = mirror_node.transform
			if olnyRot do(
				new_tm.row4 = copy obj.transform[4]
				new_tm = GeTnormalizeTm new_tm obj.transform.scalepart
			)
			obj.transform = new_tm
		)
	)
	delete mirror_nodes
	redrawViews()
)
fn GetHierarchyNodes arg_nodes = (
	root_nodes = #()
	for obj in arg_nodes do (
		isRoot = false 
		if obj.parent == undefined then isRoot = true 
			else(
				p_node = obj.parent
				isRoot = true
				for select_node in arg_nodes do ( 
					if p_node == select_node do isRoot = false
				)
			)
		if isRoot do append root_nodes obj
	)
	new_sort_nodes = #()
	for obj in root_nodes do (
		sort_list = #()
		sort_list  = for n in obj collect  n
		for sub_node in sort_list do(
			-- 대상 노드만 포함
			isSelectionNode = false
			for t_node in arg_nodes do (
				if sub_node == t_node do isSelectionNode = true
			)
			if isSelectionNode do append new_sort_nodes sub_node
		)
	)
	new_sort_nodes
)
fn SaveSceneObjPos arg_obj:(objects as array) = (
	tm_list = #()
	root_nodes = #()
	for obj in arg_obj do (
		isRoot = false 
		if obj.parent == undefined then isRoot = true 
			else(
				p_node = obj.parent
				isRoot = true
				for select_node in arg_obj do ( 
					if p_node == select_node do isRoot = false
				)
			)
		if isRoot do append root_nodes obj
	)
	new_sort_nodes = #()
	for obj in root_nodes do (
		sort_list = #()
		sort_list  = for n in obj collect  n
		for sub_node in sort_list do(
			-- 대상 노드만 포함
			isSelectionNode = false
			for t_node in arg_obj do (
				if sub_node == t_node do isSelectionNode = true
			)
			if isSelectionNode do append new_sort_nodes sub_node
		)
	)
	for obj in new_sort_nodes do (
		tm_data = objTm()
		tm_data.name = obj.name
		tm_data.id =obj.handle
		tm = obj.transform
		if obj.parent != undefined do (
			tm = obj.transform * (inverse obj.parent.transform)
		)
		tm_data.tm = tm
		append tm_list  tm_data
	)
	tm_list
)
fn LoadScenePos tm_list_arg  olnyRot:false = (
	animate on (
		for tm in tm_list_arg do (
			for obj in objects as array do (
				if tm.id == obj.handle do (
					key_tm =  tm.tm
					if obj.parent == undefined do (
						new_tm = key_tm
					)
					if obj.parent != undefined do (
						new_tm = key_tm * obj.parent.transform
					)
					if olnyRot do(
						new_tm.row4 = copy obj.transform[4]
						new_tm = GeTnormalizeTm new_tm obj.transform.scalepart
					)
					obj.transform = new_tm
					redrawViews()
				)
			)
		)
	)
)
fn LoadPosByHierarchy tm_list_arg  olnyRot:false = (
	target_nodes = GetHierarchyNodes (selection as array)
	animate on (
		for i = 1 to tm_list_arg.count do (
			key_tm = tm_list_arg[i].tm
			obj = target_nodes[i] 
			if obj == undefined do return ((i as string) + "개를 완료")
			if obj.parent == undefined then (
				new_tm = key_tm
			)
			else (
				new_tm = key_tm * obj.parent.transform
			)
			if olnyRot do(
				new_tm.row4 = copy obj.transform[4]
				new_tm = GeTnormalizeTm new_tm obj.transform.scalepart
			)
			obj.transform = new_tm
			redrawViews()
		)
	)
	"작업완료"
)
fn LoadTmByName tm_list_arg olnyRot:false = (
	isfalse = false
	for tm in tm_list_arg do (
		i = 0
		for obj in (selection as array) do(
			if obj.name == tm.name do i += 1
		)
		if i > 1 do isfalse = true
	)
	if isfalse do (
		if not queryBox  "중복된 오브젝트가 있습니다. 진행하기겠습니까?" do return false
	)
	animate on (
		for tm in tm_list_arg do (
			for obj in (selection as array) do (
				if tm.name == obj.name do (
					key_tm =  tm.tm
					if obj.parent == undefined do (
						new_tm = key_tm
					)
					if obj.parent != undefined do (
						new_tm = key_tm	* obj.parent.transform
					)
					if olnyRot do new_tm.row4 = copy obj.transform[4]
					obj.transform = new_tm
					redrawViews()
				)
			)
		)
	)
	true
)
rollout SaveLoadObjPos "신 포즈 저장 불러오기"
(
	local tm_list = #()
	local posCopyItemList = #()
	local LoadPosNames = #()
	local save_text_pre = "저정된 해당 오브젝트 : "
	button reset_btn "Data Reset" tooltip:"저장된 정보를 삭제"
	label file_name "저장파일명" style_sunkenedge:true tooltip:"저장된 파일이름"
	label save_text "0 개 저장중"
	label log_text "대기중..."
	label aaa  "ㅁ----------------------ㅁ"
	edittext saveName text:"저장할 포즈명"
	button save_btn "Save Pos"
	label bbb  "ㅁ----------------------ㅁ"
	dropdownlist loadPosList item:LoadPosNames
	checkbox olnyrot_ck "Olny Rotation"
	button load_btn "Load Pos" tooltip:"원본 본만 적용"
	button loadByName_btn "Load pos By Name" tooltip:"해당 이름대로 복사."
	button loadHierarchy_btn "Load by Hierarchy" tooltip:"계층구조로 대로 복사한다."
	button mirrorX_btn "Mirror X" tooltip:"계층구조로 대로 복사한다."
	
	fn getSaveText arg_int = (
		return_str = save_text_pre + (arg_int as string) + "개"
	)
	on save_btn pressed do (
		undo on(
		save_num_string = "0"
		newTmItem = posCopyTmList()
		nodes = selection as array
		if nodes.count == 0 do nodes = objects as array
		tm_list = SaveSceneObjPos arg_obj:nodes
		if tm_list.count > 0 do(
			log_text.text = (tm_list.count as string) + "개의 정보를 저장했습니다."
			newTmItem.index = posCopyItemList.count
			newTmitem.text = saveName.text
			newTmitem.tmList = tm_list
			save_num_string = (tm_list.count as string)
			append posCopyItemList newTmitem
		)
		LoadPosNames = #()
		for item in posCopyItemList do (
			append LoadPosNames item.text
		)
		loadPosList.items  = LoadPosNames
		save_text.text = save_text_pre + save_num_string + "개"
		file_name.text = maxfilename
		)
	)
	on load_btn pressed do (
		undo on(
		log_text.text ="불러오기 실행중"
		index = loadPosList.selection
		if index == 0 do return log_text.text ="불러올 목록을 선택하세요."
		tm_list = posCopyItemList[index].tmList
		save_text.text = getSaveText tm_list.count
		LoadScenePos tm_list olnyRot:olnyrot_ck.state
		if tm_list.count == 0 then log_text.text ="저장된 포즈정보가 없습니다."
		else log_text.text ="불러오기 완료"
		)
	)
	on loadByName_btn pressed do (
		undo on(
		index = loadPosList.selection
		if index == 0 do return log_text.text ="불러올 목록을 선택하세요."
		tm_list = posCopyItemList[index].tmList
		save_text.text = getSaveText tm_list.count
		if tm_list.count == 0 do (
			return (log_text.text = "저장된 포즈정보가 없습니다.")
		)
		if LoadTmByName tm_list olnyRot:olnyrot_ck.state then log_text.text ="불러오기 완료"
		else log_text.text ="중복된 이름이 있습니다."
		)
	)
	on loadHierarchy_btn pressed do (
		undo on(
		index = loadPosList.selection
		if index == 0 do return log_text.text ="불러올 목록을 선택하세요."
		tm_list = posCopyItemList[index].tmList
		save_text.text = getSaveText tm_list.count
		text_dummy =  LoadPosByHierarchy tm_list olnyRot:olnyrot_ck.state
		log_text.text = text_dummy
		)
	)
	on mirrorX_btn pressed do (
		undo on(
		index = loadPosList.selection
		if index == 0 do return log_text.text ="불러올 목록을 선택하세요."
		tm_list = posCopyItemList[index].tmList
		save_text.text = getSaveText tm_list.count
		SetMirrorNodes tm_list olnyRot:olnyrot_ck.state
		log_text.text = "값 x축 미러로 적용완료"
		)
	)
	on reset_btn pressed do (
		tm_list = #()
		LoadPosNames = #()
		posCopyItemList = #()
		loadPosList.items  = LoadPosNames
		log_text.text = "저장된 정보를 삭제함."
		save_text.text = getSaveText tm_list.count
	)
)
createdialog SaveLoadObjPos 180 300 style:#(#style_titlebar, #style_resizing, #style_sysmenu)
