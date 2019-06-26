import com.avos.avoscloud.AVException;
import com.avos.avoscloud.AVOSCloud;
import com.avos.avoscloud.AVQuery;
import com.avos.avoscloud.AVObject;
import java.util.List;

class Leancloud {
    public static void main(String[] args) throws AVException {
        String applicationId = "YHMwvrTgcfDjOXmiGY3jQ2r5-gzGzoHsz";
        String clientKey = "JRfKfM8mRPgxMB9GOSAnix9W";
        String masterKey = "3gteH2sDgTs9njsoxzWrXppk";
        AVOSCloud.setDebugLogEnabled(true);
        AVOSCloud.useAVCloudCN();
        AVOSCloud.initialize(applicationId, clientKey, masterKey);

        AVQuery<AVObject> avQuery = new AVQuery<AVObject>("Counter");
        List<AVObject> counters = avQuery.find();
        for (AVObject counter : counters) {
            counter.put("url", counter.getString("url").toLowerCase());
        }
        AVObject.saveAll(counters);
    }
}