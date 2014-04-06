(ns radsticks.db.snippet
  (:require [radsticks.util :as util]
            [radsticks.db.core :refer [db-spec]]
            [yesql.core :refer [defqueries]]
            [clj-time.coerce :refer [to-sql-time]]
            [clojure.java.jdbc :as jdbc]))


(defn load-queries! []
  (defqueries "sql/queries/snippet.sql"))
(load-queries!)


(defn create! [user-email, content, tags]
  (let [created (to-sql-time (util/datetime))
        updated (to-sql-time (util/datetime))
        result (-create-snippet<! db-spec
                                  user-email
                                  content
                                  tags
                                  created
                                  updated)]
    (if (not (nil? result))
      (:id result)
      nil)))


(defn update! [snippet-id content tags]
  (let [updated (to-sql-time (util/datetime))]
    (-update-snippet! db-spec content tags updated snippet-id)))


(defn exists? [snippet-id]
  (let [result (first (-snippet-exists? db-spec snippet-id))]
    (:exists result)))


;; We need to use a transaction so we can convert :tags to a vec
;; before the connection is closed
(defn get-by-id [snippet-id]
  (if (exists? snippet-id)
    (jdbc/with-db-transaction [conn db-spec]
      (let [row (first (-get-snippet conn snippet-id))]
        (update-in row [:tags] (fn [ts] (vec (.getArray ts))))))
    nil))


(defn get-snippet-owner [id]
  (if (exists? id)
    (let [snippet (get-by-id id)]
      (:user_id snippet))
    nil))


(defn delete! [id]
  (-delete-snippet! db-spec id))
