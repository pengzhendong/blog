import leancloud
class Utils(object):
    def __init__(self):
        leancloud.init('YHMwvrTgcfDjOXmiGY3jQ2r5-gzGzoHsz', 'JRfKfM8mRPgxMB9GOSAnix9W')
        self.query = leancloud.Query('Counter')
    
    def leancloud_query(self):
        for item in self.query.find():
            print(item.get('time')) 

    def leancloud_update(self):
        item = self.query.get('5d1427dc43e78ca283a5f57c')
        item.set('createdAt', '2016-01-15T02:20:12.213Z')
        item.save()

if __name__ == "__main__":
    utils = Utils()
    utils.leancloud_query()

    

    
