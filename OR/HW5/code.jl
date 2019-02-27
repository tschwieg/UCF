using JuMP
using Cbc
m = Model( solver = CbcSolver() )
@variable( m, x[0:9] >= 0)
@variable( m, s[0:9] >= 0)
@variable( m, y01, Bin)
@variable( m, y02, Bin)
@variable( m, y03, Bin)
@variable( m, y04, Bin)
@variable( m, y05, Bin)
@variable( m, y06, Bin)
@variable( m, y07, Bin)
@variable( m, y08, Bin)
@variable( m, y09, Bin)
@variable( m, y10, Bin)
@variable( m, y12, Bin)
@variable( m, y13, Bin)
@variable( m, y14, Bin)
@variable( m, y15, Bin)
@variable( m, y16, Bin)
@variable( m, y17, Bin)
@variable( m, y18, Bin)
@variable( m, y19, Bin)
@variable( m, y20, Bin)
@variable( m, y21, Bin)
@variable( m, y23, Bin)
@variable( m, y24, Bin)
@variable( m, y25, Bin)
@variable( m, y26, Bin)
@variable( m, y27, Bin)
@variable( m, y28, Bin)
@variable( m, y29, Bin)
@variable( m, y30, Bin)
@variable( m, y31, Bin)
@variable( m, y32, Bin)
@variable( m, y34, Bin)
@variable( m, y35, Bin)
@variable( m, y36, Bin)
@variable( m, y37, Bin)
@variable( m, y38, Bin)
@variable( m, y39, Bin)
@variable( m, y40, Bin)
@variable( m, y41, Bin)
@variable( m, y42, Bin)
@variable( m, y43, Bin)
@variable( m, y45, Bin)
@variable( m, y46, Bin)
@variable( m, y47, Bin)
@variable( m, y48, Bin)
@variable( m, y49, Bin)
@variable( m, y50, Bin)
@variable( m, y51, Bin)
@variable( m, y52, Bin)
@variable( m, y53, Bin)
@variable( m, y54, Bin)
@variable( m, y56, Bin)
@variable( m, y57, Bin)
@variable( m, y58, Bin)
@variable( m, y59, Bin)
@variable( m, y60, Bin)
@variable( m, y61, Bin)
@variable( m, y62, Bin)
@variable( m, y63, Bin)
@variable( m, y64, Bin)
@variable( m, y65, Bin)
@variable( m, y67, Bin)
@variable( m, y68, Bin)
@variable( m, y69, Bin)
@variable( m, y70, Bin)
@variable( m, y71, Bin)
@variable( m, y72, Bin)
@variable( m, y73, Bin)
@variable( m, y74, Bin)
@variable( m, y75, Bin)
@variable( m, y76, Bin)
@variable( m, y78, Bin)
@variable( m, y79, Bin)
@variable( m, y80, Bin)
@variable( m, y81, Bin)
@variable( m, y82, Bin)
@variable( m, y83, Bin)
@variable( m, y84, Bin)
@variable( m, y85, Bin)
@variable( m, y86, Bin)
@variable( m, y87, Bin)
@variable( m, y89, Bin)
@variable( m, y90, Bin)
@variable( m, y91, Bin)
@variable( m, y92, Bin)
@variable( m, y93, Bin)
@variable( m, y94, Bin)
@variable( m, y95, Bin)
@variable( m, y96, Bin)
@variable( m, y97, Bin)
@variable( m, y98, Bin)
@variable( m, Z, Bin)
@objective( m, Min, 1*s[0] + 2*s[1] + 5*s[2] + 1*s[3] + 3*s[4] + 5*s[5] + 2*s[6] + 4*s[7] + 3*s[8] + 7*s[9])
@constraint( m, x[0] - s[0] <= 20 - 10)
@constraint( m, x[1] - s[1] <= 98 - 3)
@constraint( m, x[2] - s[2] <= 100 - 13)
@constraint( m, x[3] - s[3] <= 34 - 15)
@constraint( m, x[4] - s[4] <= 50 - 9)
@constraint( m, x[5] - s[5] <= 44 - 22)
@constraint( m, x[6] - s[6] <= 32 - 17)
@constraint( m, x[7] - s[7] <= 60 - 30)
@constraint( m, x[8] - s[8] <= 80 - 12)
@constraint( m, x[9] - s[9] <= 150 - 16)
@constraint( m, 10000*y10 + x[1] - x[0] >= 10)
@constraint( m, 10000*y01 + x[0] - x[1] >= 3)
@constraint( m, y10+ y01 == 1)
@constraint( m, 10000*y20 + x[2] - x[0] >= 10)
@constraint( m, 10000*y02 + x[0] - x[2] >= 13)
@constraint( m, y20+ y02 == 1)
@constraint( m, 10000*y21 + x[2] - x[1] >= 3)
@constraint( m, 10000*y12 + x[1] - x[2] >= 13)
@constraint( m, y21+ y12 == 1)
@constraint( m, 10000*y30 + x[3] - x[0] >= 10)
@constraint( m, 10000*y03 + x[0] - x[3] >= 15)
@constraint( m, y30+ y03 == 1)
@constraint( m, 10000*y31 + x[3] - x[1] >= 3)
@constraint( m, 10000*y13 + x[1] - x[3] >= 15)
@constraint( m, y31+ y13 == 1)
@constraint( m, 10000*y32 + x[3] - x[2] >= 13)
@constraint( m, 10000*y23 + x[2] - x[3] >= 15)
@constraint( m, y32+ y23 == 1)
@constraint( m, 10000*y40 + x[4] - x[0] >= 10)
@constraint( m, 10000*y04 + x[0] - x[4] >= 9)
@constraint( m, y40+ y04 == 1)
@constraint( m, 10000*y41 + x[4] - x[1] >= 3)
@constraint( m, 10000*y14 + x[1] - x[4] >= 9)
@constraint( m, y41+ y14 == 1)
@constraint( m, 10000*y42 + x[4] - x[2] >= 13)
@constraint( m, 10000*y24 + x[2] - x[4] >= 9)
@constraint( m, y42+ y24 == 1)
@constraint( m, 10000*y43 + x[4] - x[3] >= 15)
@constraint( m, 10000*y34 + x[3] - x[4] >= 9)
@constraint( m, y43+ y34 == 1)
@constraint( m, 10000*y50 + x[5] - x[0] >= 10)
@constraint( m, 10000*y05 + x[0] - x[5] >= 22)
@constraint( m, y50+ y05 == 1)
@constraint( m, 10000*y51 + x[5] - x[1] >= 3)
@constraint( m, 10000*y15 + x[1] - x[5] >= 22)
@constraint( m, y51+ y15 == 1)
@constraint( m, 10000*y52 + x[5] - x[2] >= 13)
@constraint( m, 10000*y25 + x[2] - x[5] >= 22)
@constraint( m, y52+ y25 == 1)
@constraint( m, 10000*y53 + x[5] - x[3] >= 15)
@constraint( m, 10000*y35 + x[3] - x[5] >= 22)
@constraint( m, y53+ y35 == 1)
@constraint( m, 10000*y54 + x[5] - x[4] >= 9)
@constraint( m, 10000*y45 + x[4] - x[5] >= 22)
@constraint( m, y54+ y45 == 1)
@constraint( m, 10000*y60 + x[6] - x[0] >= 10)
@constraint( m, 10000*y06 + x[0] - x[6] >= 17)
@constraint( m, y60+ y06 == 1)
@constraint( m, 10000*y61 + x[6] - x[1] >= 3)
@constraint( m, 10000*y16 + x[1] - x[6] >= 17)
@constraint( m, y61+ y16 == 1)
@constraint( m, 10000*y62 + x[6] - x[2] >= 13)
@constraint( m, 10000*y26 + x[2] - x[6] >= 17)
@constraint( m, y62+ y26 == 1)
@constraint( m, 10000*y63 + x[6] - x[3] >= 15)
@constraint( m, 10000*y36 + x[3] - x[6] >= 17)
@constraint( m, y63+ y36 == 1)
@constraint( m, 10000*y64 + x[6] - x[4] >= 9)
@constraint( m, 10000*y46 + x[4] - x[6] >= 17)
@constraint( m, y64+ y46 == 1)
@constraint( m, 10000*y65 + x[6] - x[5] >= 22)
@constraint( m, 10000*y56 + x[5] - x[6] >= 17)
@constraint( m, y65+ y56 == 1)
@constraint( m, 10000*y70 + x[7] - x[0] >= 10)
@constraint( m, 10000*y07 + x[0] - x[7] >= 30)
@constraint( m, y70+ y07 == 1)
@constraint( m, 10000*y71 + x[7] - x[1] >= 3)
@constraint( m, 10000*y17 + x[1] - x[7] >= 30)
@constraint( m, y71+ y17 == 1)
@constraint( m, 10000*y72 + x[7] - x[2] >= 13)
@constraint( m, 10000*y27 + x[2] - x[7] >= 30)
@constraint( m, y72+ y27 == 1)
@constraint( m, 10000*y73 + x[7] - x[3] >= 15)
@constraint( m, 10000*y37 + x[3] - x[7] >= 30)
@constraint( m, y73+ y37 == 1)
@constraint( m, 10000*y74 + x[7] - x[4] >= 9)
@constraint( m, 10000*y47 + x[4] - x[7] >= 30)
@constraint( m, y74+ y47 == 1)
@constraint( m, 10000*y75 + x[7] - x[5] >= 22)
@constraint( m, 10000*y57 + x[5] - x[7] >= 30)
@constraint( m, y75+ y57 == 1)
@constraint( m, 10000*y76 + x[7] - x[6] >= 17)
@constraint( m, 10000*y67 + x[6] - x[7] >= 30)
@constraint( m, y76+ y67 == 1)
@constraint( m, 10000*y80 + x[8] - x[0] >= 10)
@constraint( m, 10000*y08 + x[0] - x[8] >= 12)
@constraint( m, y80+ y08 == 1)
@constraint( m, 10000*y81 + x[8] - x[1] >= 3)
@constraint( m, 10000*y18 + x[1] - x[8] >= 12)
@constraint( m, y81+ y18 == 1)
@constraint( m, 10000*y82 + x[8] - x[2] >= 13)
@constraint( m, 10000*y28 + x[2] - x[8] >= 12)
@constraint( m, y82+ y28 == 1)
@constraint( m, 10000*y83 + x[8] - x[3] >= 15)
@constraint( m, 10000*y38 + x[3] - x[8] >= 12)
@constraint( m, y83+ y38 == 1)
@constraint( m, 10000*y84 + x[8] - x[4] >= 9)
@constraint( m, 10000*y48 + x[4] - x[8] >= 12)
@constraint( m, y84+ y48 == 1)
@constraint( m, 10000*y85 + x[8] - x[5] >= 22)
@constraint( m, 10000*y58 + x[5] - x[8] >= 12)
@constraint( m, y85+ y58 == 1)
@constraint( m, 10000*y86 + x[8] - x[6] >= 17)
@constraint( m, 10000*y68 + x[6] - x[8] >= 12)
@constraint( m, y86+ y68 == 1)
@constraint( m, 10000*y87 + x[8] - x[7] >= 30)
@constraint( m, 10000*y78 + x[7] - x[8] >= 12)
@constraint( m, y87+ y78 == 1)
@constraint( m, 10000*y90 + x[9] - x[0] >= 10)
@constraint( m, 10000*y09 + x[0] - x[9] >= 16)
@constraint( m, y90+ y09 == 1)
@constraint( m, 10000*y91 + x[9] - x[1] >= 3)
@constraint( m, 10000*y19 + x[1] - x[9] >= 16)
@constraint( m, y91+ y19 == 1)
@constraint( m, 10000*y92 + x[9] - x[2] >= 13)
@constraint( m, 10000*y29 + x[2] - x[9] >= 16)
@constraint( m, y92+ y29 == 1)
@constraint( m, 10000*y93 + x[9] - x[3] >= 15)
@constraint( m, 10000*y39 + x[3] - x[9] >= 16)
@constraint( m, y93+ y39 == 1)
@constraint( m, 10000*y94 + x[9] - x[4] >= 9)
@constraint( m, 10000*y49 + x[4] - x[9] >= 16)
@constraint( m, y94+ y49 == 1)
@constraint( m, 10000*y95 + x[9] - x[5] >= 22)
@constraint( m, 10000*y59 + x[5] - x[9] >= 16)
@constraint( m, y95+ y59 == 1)
@constraint( m, 10000*y96 + x[9] - x[6] >= 17)
@constraint( m, 10000*y69 + x[6] - x[9] >= 16)
@constraint( m, y96+ y69 == 1)
@constraint( m, 10000*y97 + x[9] - x[7] >= 30)
@constraint( m, 10000*y79 + x[7] - x[9] >= 16)
@constraint( m, y97+ y79 == 1)
@constraint( m, 10000*y98 + x[9] - x[8] >= 12)
@constraint( m, 10000*y89 + x[8] - x[9] >= 16)
@constraint( m, y98+ y89 == 1)
@constraint( m, x[2] - x[3] - 15 <= 10000*(1-Z)- 0.0001)
@constraint( m, x[8] + 12 - x[2] <= 10000*Z)
status = solve(m)
println( "Objective Value: ", getobjectivevalue(m))
println( getvalue( x ))
println( getvalue( s ))