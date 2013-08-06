from firebase import firebase
import json

db = firebase.FirebaseApplication('https://react.firebaseio.com', None)
result = db.get('/users', None)

fastest = dict()

for xid in result.keys():
	xid_timings = []
	for section in result[xid]:
		if section == unicode("sessions"):
			# print result[xid][section]
			for session in result[xid][section].values():
				for detail in session:
					if detail == unicode("timings"):
						for t in session[detail]:
							xid_timings.append(t)
		if section == unicode("meta"):
			for trait in result[xid][section].keys():
				if trait == unicode("name"):
					name = str(result[xid][section][trait])

	xid_timings.sort()
	if len(xid_timings)>0:
		print(xid_timings)
		info = dict()
		info['name'] = name
		info['xid'] = xid
		fastest[xid_timings[0]] = info
		print("fastest = " + str(xid_timings[0]))
		median = 0
		n = len(xid_timings)
		if n%2 == 0:
			median = (xid_timings[n/2] + xid_timings[n/2-1])/2
		else:
			median = xid_timings[int(n/2)]

		print("median = " + str(median))

		# data = {'fastest': xid_timings[0], 'median': median}
		# db.put('/users/' + str(xid), 'performance', data)
print(fastest)
ranked = dict()
print(sorted(fastest.iterkeys()))

rank = 1
for key in sorted(fastest.iterkeys()):
	instance = dict()
	instance['value'] = key
	instance['xid'] = fastest[key]['xid']
	instance['name'] = fastest[key]['name']
	ranked[rank] = instance
	rank+=1

print(ranked)
db.put('/stats', 'global_rank', ranked)