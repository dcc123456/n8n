import { OpenAIEmbeddings } from '@langchain/openai';
import {
	NodeConnectionTypes,
	type INodeType,
	type INodeTypeDescription,
	type ISupplyDataFunctions,
	type SupplyData,
} from 'n8n-workflow';

import { logWrapper } from '@utils/logWrapper';
import { getConnectionHintNoticeField } from '@utils/sharedFields';

export class EmbeddingsSiliconFlow implements INodeType {
	description: INodeTypeDescription = {
		displayName: 'Embeddings SiliconFlow',
		name: 'embeddingsSiliconFlow',
		icon: 'file:siliconflow.svg',
		group: ['transform'],
		version: 1,
		description: 'Use SiliconFlow Embeddings',
		defaults: {
			name: 'Embeddings SiliconFlow',
		},
		credentials: [
			{
				name: 'siliconFlowApi',
				required: true,
			},
		],
		codex: {
			categories: ['AI'],
			subcategories: {
				AI: ['Embeddings'],
			},
			resources: {
				primaryDocumentation: [
					{
						url: 'https://docs.siliconflow.cn/',
					},
				],
			},
		},

		inputs: [],

		outputs: [NodeConnectionTypes.AiEmbedding],
		outputNames: ['Embeddings'],
		properties: [
			getConnectionHintNoticeField([NodeConnectionTypes.AiVectorStore]),
			{
				displayName:
					'Each model is using different dimensional density for embeddings. Please make sure to use the same dimensionality for your vector store. Check SiliconFlow documentation for specific dimensions.',
				name: 'notice',
				type: 'notice',
				default: '',
			},
			{
				displayName: 'Model Name',
				name: 'modelName',
				type: 'string',
				default: 'netease-youdao/bce-embedding-base_v1',
				description: 'The model name to use from SiliconFlow library',
			},
			{
				displayName: 'Options',
				name: 'options',
				placeholder: 'Add Option',
				description: 'Additional options to add',
				type: 'collection',
				default: {},
				options: [
					{
						displayName: 'Custom Inference Endpoint',
						name: 'endpointUrl',
						default: '',
						description: 'Custom endpoint URL',
						type: 'string',
					},
				],
			},
		],
	};

	async supplyData(this: ISupplyDataFunctions, itemIndex: number): Promise<SupplyData> {
		this.logger.debug('Supply data for embeddings SiliconFlow');
		const model = this.getNodeParameter(
			'modelName',
			itemIndex,
			'netease-youdao/bce-embedding-base_v1',
		) as string;
		const credentials = await this.getCredentials('siliconFlowApi');
		const options = this.getNodeParameter('options', itemIndex, {}) as object;

		const embeddings = new OpenAIEmbeddings({
			model,
			apiKey: credentials.apiKey as string,
			configuration: {
				baseURL: 'https://api.siliconflow.cn/v1',
			},
			...options,
		});

		return {
			response: logWrapper(embeddings, this),
		};
	}
}