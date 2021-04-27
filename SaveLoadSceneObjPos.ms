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
fn SaveSceneObjPos arg_obj:(objects as array) = (
	tm_list = #()
	
	for obj in arg_obj do (
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
fn LoadScenePos tm_list_arg = (
	animate on (
		for tm in tm_list_arg do (
			for obj in objects as array do (
				if tm.id == obj.handle do (
					if obj.parent == undefined do (
						obj.transform = tm.tm
					)
					if obj.parent != undefined do (
						obj.transform = tm.tm * obj.parent.transform
					)
				)
			)
		)
	)
)
fn LoadTmByName tm_list_arg = (
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
					if obj.parent == undefined do (
						obj.transform = tm.tm
					)
					if obj.parent != undefined do (
						obj.transform = tm.tm * obj.parent.transform
					)
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
	
	label file_name "저장파일명" style_sunkenedge:true tooltip:"저장된 파일이름"
	label save_text "0 개 저장중"
	label log_text "대기중..."
	label aaa  "ㅁ----------------------ㅁ"
	edittext saveName text:"저장할 포즈명"
	button save_btn "Save Pos"
	label bbb  "ㅁ----------------------ㅁ"
	dropdownlist loadPosList item:LoadPosNames
	button load_btn "Load Pos"
	button loadByName_btn "Load pos By Name"
	
	on save_btn pressed do (
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
		save_text.text = save_num_string + "개 저장중"
		file_name.text = maxfilename
	)
	on load_btn pressed do (
		log_text.text ="불러오기 실행중"
		index = loadPosList.selection
		if indes == 0 do return log_text.text ="불러올 목록을 선택하세요."
		tm_list = posCopyItemList[index].tmList
		LoadScenePos tm_list
		if tm_list.count == 0 then log_text.text ="저장된 포즈정보가 없습니다."
			else log_text.text ="불러오기 완료"
	)
	on loadByName_btn pressed do (
		index = loadPosList.selection
		if indes == 0 do return log_text.text ="불러올 목록을 선택하세요."
		tm_list = posCopyItemList[index].tmList
		if LoadTmByName tm_list then log_text.text ="불러오기 완료"
			else log_text.text ="중복된 이름이 있습니다."
	)
)
createdialog SaveLoadObjPos 180 250 style:#(#style_titlebar, #style_resizing, #style_sysmenu)
