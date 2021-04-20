addgroup --gid 3003 inet
userdel _apt

if grep "LAST_GUID=199999" /etc/adduser.conf; then
else
	cat >> /etc/adduser.conf << EOF
EXTRA_GROUPS="inet"
ADD_EXTRA_GROUPS=1

FIRST_UID=100501
LAST_UID=199999

FIRST_GID=100501
LAST_GID=199999
EOF
fi

adduser --system --no-create-home --force-badname _apt

