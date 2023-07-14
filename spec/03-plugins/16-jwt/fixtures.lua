-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local helpers = require "spec.helpers"
local u = helpers.unindent

return {
rs256_private_key = [[
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAw5mp3MS3hVLkHwB9lMrEx34MjYCmKeH/XeMLexNpTd1FzuNv
6rArovTY763CDo1Tp0xHz0LPlDJJtpqAgsnfDwCcgn6ddZTo1u7XYzgEDfS8J4SY
dcKxZiSdVTpb9k7pByXfnwK/fwq5oeBAJXISv5ZLB1IEVZHhUvGCH0udlJ2vadqu
R03phBHcvlNmMbJGWAetkdcKyi+7TaW7OUSjlge4WYERgYzBB6eJH+UfPjmw3aSP
ZcNXt2RckPXEbNrL8TVXYdEvwLJoJv9/I8JPFLiGOm5uTMEk8S4txs2efueg1Xyy
milCKzzuXlJvrvPA4u6HI7qNvuvkvUjQmwBHgwIDAQABAoIBAQCP3ZblTT8abdRh
xQ+Y/+bqQBjlfwk4ZwRXvuYz2Rwr7CMrP3eSq4785ZAmAaxo3aP4ug9bL23UN4Sm
LU92YxqQQ0faZ1xTHnp/k96SGKJKzYYSnuEwREoMscOS60C2kmWtHzsyDmhg/bd5
i6JCqHuHtPhsYvPTKGANjJrDf+9gXazArmwYrdTnyBeFC88SeRG8uH2lP2VyqHiw
ZvEQ3PkRRY0yJRqEtrIRIlgVDuuu2PhPg+MR4iqR1RONjDUFaSJjR7UYWY/m/dmg
HlalqpKjOzW6RcMmymLKaW6wF3y8lbs0qCjCYzrD3bZnlXN1kIw6cxhplfrSNyGZ
BY/qWytJAoGBAO8UsagT8tehCu/5smHpG5jgMY96XKPxFw7VYcZwuC5aiMAbhKDO
OmHxYrXBT/8EQMIk9kd4r2JUrIx+VKO01wMAn6fF4VMrrXlEuOKDX6ZE1ay0OJ0v
gCmFtKB/EFXXDQLV24pgYgQLxnj+FKFV2dQLmv5ZsAVcmBHSkM9PBdUlAoGBANFx
QPuVaSgRLFlXw9QxLXEJbBFuljt6qgfL1YDj/ANgafO8HMepY6jUUPW5LkFye188
J9wS+EPmzSJGxdga80DUnf18yl7wme0odDI/7D8gcTfu3nYcCkQzeykZNGAwEe+0
SvhXB9fjWgs8kFIjJIxKGmlMJRMHWN1qaECEkg2HAoGBAIb93EHW4as21wIgrsPx
5w8up00n/d7jZe2ONiLhyl0B6WzvHLffOb/Ll7ygZhbLw/TbAePhFMYkoTjCq++z
UCP12i/U3yEi7FQopWvgWcV74FofeEfoZikLwa1NkV+miUYskkVTnoRCUdJHREbE
PrYnx2AOLAEbAxItHm6vY8+xAoGAL85JBePpt8KLu+zjfximhamf6C60zejGzLbD
CgN/74lfRcoHS6+nVs73l87n9vpZnLhPZNVTo7QX2J4M5LHqGj8tvMFyM895Yv+b
3ihnFVWjYh/82Tq3QS/7Cbt+EAKI5Yzim+LJoIZ9dBkj3Au3eOolMym1QK2ppAh4
uVlJORsCgYBv/zpNukkXrSxVHjeZj582nkdAGafYvT0tEQ1u3LERgifUNwhmHH+m
1OcqJKpbgQhGzidXK6lPiVFpsRXv9ICP7o96FjmQrMw2lAfC7stYnFLKzv+cj8L9
h4hhNWM6i/DHXjPsHgwdzlX4ulq8M7dR8Oqm9DrbdAyWz8h8/kzsnA==
-----END RSA PRIVATE KEY-----
]],
rs256_public_key = [[
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw5mp3MS3hVLkHwB9lMrE
x34MjYCmKeH/XeMLexNpTd1FzuNv6rArovTY763CDo1Tp0xHz0LPlDJJtpqAgsnf
DwCcgn6ddZTo1u7XYzgEDfS8J4SYdcKxZiSdVTpb9k7pByXfnwK/fwq5oeBAJXIS
v5ZLB1IEVZHhUvGCH0udlJ2vadquR03phBHcvlNmMbJGWAetkdcKyi+7TaW7OUSj
lge4WYERgYzBB6eJH+UfPjmw3aSPZcNXt2RckPXEbNrL8TVXYdEvwLJoJv9/I8JP
FLiGOm5uTMEk8S4txs2efueg1XyymilCKzzuXlJvrvPA4u6HI7qNvuvkvUjQmwBH
gwIDAQAB
-----END PUBLIC KEY-----
]],
rs384_private_key = [[
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAp2J9bKOoexMVtI3fRPYT/eLSY620JGGD89nddKIGWaD5T0FN
rHP/P6xgTcQLUX8v+PIvvE91QCO44HXD3e+eqoOtOiDG/aF/MDHxdrt1lHIMaLk9
Ketp1nTZIQRAm+0vbR/ybjF1jVDsd6tvmbUreAHY4e1K2zpu7NssYr6WyBffPgL+
6ASnrgcHqiGCMtnI2LgSCvwc8W7zjdE1sKJfpKvM8xOVVaLEDEMnDs5VZOxsza1b
1TxqWZirxZ8xvUJtmgnpr2lwGTP+CPiEVuPciXXIZUJOGWupmKnaYa/8CewY7WDz
YEQ/S9mmf+djnNWH1TW7/e3VcyS+ZhUD+JOSCQIDAQABAoIBABWgsDwdWWOtr5xI
yJSMh0DC0hR3GVOqFfaoK+kqFk/2cMBA29xwkIaVq0vhDOVW3cf44xod2jSTaQv3
q3s9vu6hXPypx4x2FY0QpvaEekjYA6p0ZObJuD8xkeymNALxvrMG8bgzQ9Eip6s+
x4jA1AEJnBB1LLru7e5E05NetPTdizacJEVFr28/D2MBHrR2Wx6vOTJ17kMlUGZ6
Sd7jQAZZH3RbDE7+2ZQe2ibKplL/QnRKt0xr/tZozOjc6jZjM8lIyHeWGt+VTSK3
nEOWxdOkXcGWwGPougcnI/Bxsa6bUzBSEvCGbrMLYvajThebnGW3zOwMGZ4obw5I
CyzAGEECgYEA2cx+OwripXpZmBi3acKWc7hoer/tghAcP7MCG8ZzGFPsY6HHfh6f
knjug0iR+vpYiG3OpwtmjB99R4/1DQ1gkgKj9cdw8NLQr9D2o2RG+KJANN7jLrJk
OD6MUh8jkNMNO84vn9LNnEK6V5MMw3+m1uIbu3IGNN/4GBgVkTcxHZUCgYEAxL5T
dhDUeUkgekSceEjuF6oYc8+ePjfrNCnQLdT9IJIiRjRR/vfLMAjbhjgAs/j6/3m2
c0XORaqzLIiQiPSlcze6jELzORZBD9ILV3qu/H/AW1svifqGWznp7KQWFsyL2rbL
pm3cPO34yw4KP4bw5d/9Q01a8K4zJJcQdGyjPaUCgYBsAB1wRbuR9xPKeicpSJa2
l3EnvViXMEnxxGB9SXD1VVhZJ3X3MlRKm7EaZLgOzmlsbZcV+m9FeK/09ou7hzCl
9q07SUTWBpP5OxOyfh07WamhDg11sHxF765BYrOOMznSuDGhfTT8EZK5rm+b2gbv
c3vw/V/ahF1QBVFcixPN6QKBgQCx7UJDo0LUkSq7CLPNIH+ajSziB6CfuiiPG0V3
PYjSXPZ8MTL6eBSc01Xc02bnXEN6qhMzuqyqWo8BtluoUEAUrBCcaqvWM+cRLK8v
JPd9yPcoZ5XdneDGPeDtLxP++Gt+mBQi5nXn8Hsw//iKrTnNWr2LkTiuM4xzCd9K
uzkCNQKBgBeMnIBFpHJMsisJT22Z4sUoFloQ4Q2lQWUO21kb7Yvk9Xj4Rdqmd8DY
LAq++70BiJpB+HKjCfoQBvAk9EUrEguKHNf6bUfFxVBT01zdTstNg31t37poI7Em
IHnbNLKXef8YL6YP7/uNn46KL61k6vkle4YdeSGBTe2SfbmIJfnO
-----END RSA PRIVATE KEY-----
]],
rs384_public_key = [[
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp2J9bKOoexMVtI3fRPYT
/eLSY620JGGD89nddKIGWaD5T0FNrHP/P6xgTcQLUX8v+PIvvE91QCO44HXD3e+e
qoOtOiDG/aF/MDHxdrt1lHIMaLk9Ketp1nTZIQRAm+0vbR/ybjF1jVDsd6tvmbUr
eAHY4e1K2zpu7NssYr6WyBffPgL+6ASnrgcHqiGCMtnI2LgSCvwc8W7zjdE1sKJf
pKvM8xOVVaLEDEMnDs5VZOxsza1b1TxqWZirxZ8xvUJtmgnpr2lwGTP+CPiEVuPc
iXXIZUJOGWupmKnaYa/8CewY7WDzYEQ/S9mmf+djnNWH1TW7/e3VcyS+ZhUD+JOS
CQIDAQAB
-----END PUBLIC KEY-----
]],
rs512_private_key = [[
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----
]],
rs512_public_key = [[
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqzdeeD1GPBQTgrf9yjKW
sWKWzHIrRY29OyNCJ/El7/u8cq7/XVSW9tvwSMvyhtZilhCsleEYb3PgUs0u0Det
mwdfn2omyQ3TfYt4Mhd+JmjXkf+i9Up+TVEJZTdaxQp0aYJEoyvfO6kh2o3tBDsL
YhTP7JxsNcae20jzvqfxl35hHzh0I0iLkjYbmL+GtIFB3krWnIhyClg/NIaCoJGS
+UeoUk5oVOHu5Bz9i51s3x3YL1Ljp5z6dorR3I4V8QDHvQB65gdOJgkqTHfEyCwN
apcTpPq/KMoE1GlFzP2A4RLy65DNazT+OXZ9tAHbeA7w1P0M4WrruagSmtnyYNeb
Fe56z2K3l1hr3d+l3qNPI63gS1ccy24Z8c3T8yMRptCdoTyikDZBj5Jl94Nwc/Ui
fAR0LzQlfFPQNVKSnBf7EGBAmseOja0hNVhSEDIh2aVhVl2Y3aovtPYlEs+tQc9K
ZSX9Bhz2/F/b38rLfIXMV4PbQ5NQ85hqiXG5Y45LwlcZxU2N/2JH25OTponRhkQ5
mwVZQKOr94ECsNztLLLxjDo1CaSuzf6S+MVdJ17pf1JuRnSKJ439esIed4qMoFo0
X9ZXoo7nZEgo5AP5LBHB58qxCiNXTGzDHk/KV1wwu6fW+Mzp8twtPbaRt+G6yyc1
swQUpq5h6dPQpzxJ03KcC/8CAwEAAQ==
-----END PUBLIC KEY-----
]],
es256_private_key = [[
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgD8enltAi05AIoF2A
fqwctkCFME0gP/HwVvnHCtatlVChRANCAAQDBOV5Pwz+uUXycT+qFj7bprEnMWuh
XPtZyIZljEHXAj9TSMmDKvk8F1ABIXLAb5CAY//EPd4SjNSdU5f7XP72
-----END PRIVATE KEY-----
]],
es256_public_key = [[
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEAwTleT8M/rlF8nE/qhY+26axJzFr
oVz7WciGZYxB1wI/U0jJgyr5PBdQASFywG+QgGP/xD3eEozUnVOX+1z+9g==
-----END PUBLIC KEY-----
]],
es384_private_key = [[
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDCZs38qGiybDKau1EXDu3amiHPCy3H0256L40Dz0apq7WACQsm1vtBG
wLyEeCB8QBWgBwYFK4EEACKhZANiAASsWme9Zvk7cD/YORhUJuB80/Qtm2v5HQvQ
BQL2L2NUEEvFHRaRXdKJpMYi7GElW2SQR1uz1dFjVH21KyL3PbxQdUgI70xIotZE
C00FKzZE3QpP2mkYhM9F7a4AaPnx5uw=
-----END EC PRIVATE KEY-----
]],
es384_public_key = [[
-----BEGIN PUBLIC KEY-----
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAErFpnvWb5O3A/2DkYVCbgfNP0LZtr+R0L
0AUC9i9jVBBLxR0WkV3SiaTGIuxhJVtkkEdbs9XRY1R9tSsi9z28UHVICO9MSKLW
RAtNBSs2RN0KT9ppGITPRe2uAGj58ebs
-----END PUBLIC KEY-----
]],
hs384_secret = u([[
zxhk1H1Y11ax99xO20EGf00FDAOuPb9kEOmOQZMpR1BElx7sWjBIX2okAJiqjulH
OZpsjcgbzfCq69apm6f2K28PTvIvS8ni_CG46_huUTBqosCmdEr-kZDvKBLsppfG
2c8q9NXu3Qi_049nCFcIqGLhPgjJDmxElRhyJrtU8PDq2sBurfsIXmRczgG6LzxY
kuQ3FRny4O4ozT6B8fsId8DZ1tMd8XyKeeEN_zgE2aFipV1ONRpSLKXyHm8Jchzz
Vu-h84FJkh3CGXdPOYxhn66asmr48rnnV-ISS0rSDe6vCwnurhgKCDHrKcHi_Ksb
tlasnT8qLZsnxop42uFBjQ
]], true),
hs512_secret = u([[
eCCyv047A0rmH2-TfDIg89JJ9Kbmo8lp5z4C9LelCV8tPPYqg-22BBtWhairPSWR
UzlpndVzRqbQMjiBTI69lCaj7zsYopJPZ_i6xVlD_XWmrx-PanZgP-AW0EiSiwqO
dNl4aNhwMuSOnTAQYrwSZMGM9xnxfo5apkxtUhgcNFzXB8oEZPzRf_xBXHlID3vl
IqZZ4pAQdi6h4XRr7lNMgwsZD5KffAGuGC4pDnuMYBCs_qz-PMEgdFUvWWNOC0ZV
RKE7AOhjUnwFOBVee6mcF0u1IB4GOXuGAUAgxVtlAdHjmmBR73-TYxE_B_yosTVN
MpnYuHBRF2gxKx1PZfHc4w
]], true)
}
