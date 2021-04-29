macroScript SaveLoadSceneObjPos
category:"_AniSeoHyun"
tooltip:"SaveLoadSceneObjPos"
icon:#("Classic",31)
(
	on execute do
	(
		filein (getdir  #userScripts + "\\SEO\\SaveLoadSceneObjPos\\SaveLoadSceneObjPos.ms")
	)
)
print "SaveLoadSceneObjPos의 단축키를 _AniSeoHyun에 등록합니다. "
current_paht = pathConfig.removePathLeaf (getSourceFileName())
ms_fileName = "SaveLoadSceneObjPos.ms"

ms_file = (getFiles (pathConfig.appendPath current_paht ms_fileName ) )[1]
ms_dir =  pathConfig.appendPath (getDir #userScripts) "\\SEO\\SaveLoadSceneObjPos"
ms_installer_path = pathConfig.appendPath ms_dir ms_fileName
isFirst = not (doesFileExist ms_installer_path)
if isFirst do 
(
	print "SaveLoadSceneObjPos 스크립트를 처음 설치중"
	if not doesDirectoryExist ms_dir do(
		if(makeDir ms_dir all:true)then(
			print "Seo \\ SaveLoadSceneObjPos 폴더를 생성중"
		)else(messageBox "폴더 생성 실패")
	)
)
if (doesFileExist ms_installer_path) do(
	deleteFile ms_installer_path
	print "기존파일 삭제함"
)
if copyFile ms_file ms_installer_path then (
	print "설치 완료"
	filein ms_installer_path
) else messageBox "파일설치 실패"



