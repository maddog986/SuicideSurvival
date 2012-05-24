DeriveGamemode("base")

GM.Name 		= "Suicide Survival"
GM.Author 	= "MadDog"
GM.Email 		= ""
GM.Website 	= ""

function GM:CreateTeams()
	TEAM_HUMANS = 1
	team.SetUp( TEAM_HUMANS, "Humans", Color( 0, 0, 180, 255 ) )

	TEAM_BARRELS = 2
	team.SetUp( TEAM_BARRELS, "Barrels", Color( 180, 0, 0, 255 ) )
end
