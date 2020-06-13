<?php

namespace Tests\Feature;

use Faker\Factory;
use Faker\Provider\Address;
use Tests\TestCase;
use Cviebrock\LaravelElasticsearch\Facade as ElasticSearch;

class ElasticTest extends TestCase
{


    public function testBasicIndexCreation()
    {
        $indexName = 'test_index';
        $data = [
            'body' => [
                'content' => 'Post test 123 123 123',
                'title'
            ],
            'index' => $indexName,
            'type' => 'database',
            'id' => 1,
        ];
        $return = ElasticSearch::index($data);
        // index is created or updated
        $this->assertTrue(in_array($return['result'], ['updated', 'created']));
        // delete index
        $response = Elasticsearch::indices()->delete(['index' => $indexName]);
        $this->assertEquals(true, $response['acknowledged']);
    }


    private function getMultiplePostsData(): array {
        $indexName = 'posts_index';
        $faker = Factory::create();
        $posts = [];
        for($i = 1; $i <= 1000; $i++){
            $title = $faker->sentence(10);
            $content = $faker->sentence(150);
            $author = $faker->name;
            $category = $faker->randomElement(['travel', 'food', 'health', 'animals']);
            $data = [
                'body' => [
                    'content' => $content,
                    'title' => $title,
                    'author' => $author,
                    'category' => $category
                ],
                'index' => $indexName,
                'type' => 'database',
                'id' => $i,
            ];
            $posts[] = $data;
        }
        return $posts;
    }

    public function _testIndexMultiplePosts()
    {
        foreach($this->getMultiplePostsData() as $post) {
            $response = ElasticSearch::index($post);
            $this->assertTrue(in_array($response['result'], ['updated', 'created']));
        }
    }


    public function testSearch(){
        $indexName = 'posts_index';
        $params = [
            'index' => $indexName,
            'body'  => [
                'query' => [
                    'match' => [
                        'content' => 'placeat'
                    ]
                ]
            ]
        ];
        $response = Elasticsearch::search($params);
        $this->assertNotEmpty($response);
    }

    public function testSearchMultipleFields(){
        $indexName = 'posts_index';
        $params = [
            'index' => $indexName,
            'body'  => [
                'query' => [
                    'multi_match' => [
                        'fields' => ['title^2', 'content', 'category^2'], // ^2 increases relevance of the field by 2
                        'query' => 'placeat'
                    ]
                ]
            ]
        ];
        $response = Elasticsearch::search($params);
        $this->assertNotEmpty($response);
        dd($response);
    }


    public function testIndicesStats(){
        $indexName = 'posts_index';
        $stats = Elasticsearch::indices()->stats(['index' => $indexName]);
        $primaries = $stats['indices'][$indexName]['primaries'];
        $this->assertGreaterThan(0, $primaries['search']['query_total']);
        dd($primaries);
    }
}
